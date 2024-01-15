local APMBussin = require("vim-apm.bus")
local Stats = require("vim-apm.reporter.stats")
local Events = require("vim-apm.event_names")

---@class APMFileReporter : APMReporter
---@field path string
---@field enabled boolean
---@field calc APMCalculator
---@field stats APMStats
---@field opts APMReporterIntervalOptions
local FileReporter = {}
FileReporter.__index = FileReporter

---@param path string
---@param opts APMReporterIntervalOptions
---@return APMFileReporter
function FileReporter.new(path, opts)

    opts = vim.tbl_extend("force", {
        report_interval = 1 * 60 * 1000,
        apm_repeat_count = 10,
        apm_period = 60 * 1000,
        apm_report_period = 5 * 1000,
    }, opts or {})

    return setmetatable({
        path = path,
        enabled = false,
        calc = Stats.APMCalculator.new(opts.apm_repeat_count, opts.apm_period),
        stats = Stats.Stats.new(),
        opts = opts,
        apms = {},
        apm_sum = 0,
    }, FileReporter)
end

---@param path string
---@return APMStatsJson
local function read_json_from_file(path)
    local list_why_oh_why = vim.fn.readfile(path)
    return vim.fn.json_decode(list_why_oh_why[1])
end

function FileReporter:enable()
    self.enabled = true

    local function write()
        vim.defer_fn(function()
            if not self.enabled then
                return
            end

            local ok, json = pcall(read_json_from_file, self.path)
            if not ok then
                json = Stats.empty_stats_json()
            end

            local merged = self.stats:merge(json)

            local file = vim.loop.fs_open(self.path, "w", 493)
            local out_json = vim.fn.json_encode(merged)
            local ok2, res = pcall(vim.loop.fs_write, file, out_json)

            if not ok2 then
                error("vim-apm: error writing to file: " .. res)
            end

            write()
        end, self.opts.report_interval)
    end
    write()

    local function apm_report()
        vim.defer_fn(function()
            if not self.enabled then
                return
            end
            self.calc:trim()

            APMBussin:emit("apm", self.calc:apm())
            APMBussin:emit("stats", self.stats:to_json())

            apm_report()
        end, self.opts.apm_report_period)
    end
    apm_report()

    ---@param motion APMMotionItem
    APMBussin:listen(Events.MOTION, function(motion)
        self.stats:motion(motion)
        self.calc:push(motion)
    end)

    APMBussin:listen(Events.INSERT_TO_TIME, function(insert_time)
        self.stats:time_to_insert(insert_time)
    end)

    APMBussin:listen(Events.WRITE, function()
        self.stats:write()
    end)
    APMBussin:listen(Events.BUF_ENTER, function()
        self.stats:buf_enter()
    end)

    ---@param event APMInsertTimeEvent
    APMBussin:listen(Events.INSERT_IN_TIME, function(event)
        self.stats:time_in_insert(event.insert_time, event.insert_char_count)
    end)
end

function FileReporter:clear()
    self.enabled = false
end

return FileReporter
