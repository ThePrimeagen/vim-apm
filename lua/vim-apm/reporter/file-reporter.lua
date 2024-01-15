local APMBussin = require("vim-apm.bus")
local APM = require("vim-apm.apm")
local Actions = require("vim-apm.actions")
local Stats = require("vim-apm.reporter.stats")

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
        report_interval = 15 * 60 * 1000,
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

function FileReporter:enable()
    self.enabled = true

    local function write()
        print("writing interval started", self.opts.report_interval)
        vim.defer_fn(function()
            print("WRITING...")
            if not self.enabled then
                return
            end
            local file = io.open(self.path, "r")
            local ok, res = pcall(io.write, self.path, vim.fn.json_encode(self.stats:to_json()))
            if not ok then
                print("vim-apm: error writing to file: " .. res)
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
    APMBussin:listen(APM.Events.MotionItem, function(motion)
        self.stats:motion(motion)
        self.calc:push(motion)
    end)

    APMBussin:listen(APM.Events.InsertTime, function(insert_time)
        self.stats:time_to_insert(insert_time)
    end)
    APMBussin:listen(Actions.WRITE, function()
        self.stats:write()
    end)
    APMBussin:listen(Actions.BUF_ENTER, function()
        self.stats:buf_enter()
    end)
end

function FileReporter:clear()
    self.enabled = false
end

return FileReporter
