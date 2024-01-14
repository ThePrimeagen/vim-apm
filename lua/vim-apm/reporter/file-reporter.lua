local utils = require("vim-apm.utils")
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
        report_interval = 5 * 60 * 1000,
        apm_repeat_count = 10,
        apm_period = 60 * 1000,
        apm_report_period = 5 * 1000,
    }, opts)

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
        vim.defer_fn(function()
            if not self.enabled then
                return
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
            APMBussin:emit("apm", self.calc.apm_sum)
            apm_report()
        end, self.opts.apm_report_period)
    end
    apm_report()

    ---@param motion APMMotionItem
    APMBussin:listen(APM.Events.MotionItem, function(motion)
        self.stats:motion(motion)
    end)

    APMBussin:listen(APM.Events.InsertTime, function(insert_time)
        self.stats:insert_time(insert_time)
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
