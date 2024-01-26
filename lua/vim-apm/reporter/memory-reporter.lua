local APMBussin = require("vim-apm.bus")
local Stats = require("vim-apm.stats")
local Events = require("vim-apm.event_names")
local Interval = require("vim-apm.interval")

---@class APMMemoryReporter : APMReporter
---@field enabled boolean
---@field opts APMReporterIntervalOptions
---@field current_stats APMStatsJson
---@field collector APMStatsCollector
local MemoryReporter = {}
MemoryReporter.__index = MemoryReporter

---@param path string
---@param opts APMReporterIntervalOptions
---@return APMMemoryReporter
function MemoryReporter.new(path, opts)
    opts = vim.tbl_extend("force", {
        report_interval = 1 * 60 * 1000,
        apm_repeat_count = 10,
        apm_period = 60 * 1000,
        apm_report_period = 5 * 1000,
    }, opts or {})

    return setmetatable({
        path = path,
        enabled = false,
        collector = Stats.StatsCollector.new(opts),
        opts = opts,
        current_stats = Stats.empty_stats_json(),
        apms = {},
        apm_sum = 0,
    }, MemoryReporter)
end

function MemoryReporter:enable()
    if self.enabled then
        return
    end
    self.enabled = true
    self.collector:enable()

    Interval.interval(function()
        self.current_stats = self.collector.stats:merge(self.current_stats)
    end, self.opts.report_interval)

    Interval.interval(function()
        if not self.enabled then
            return
        end
        self.collector.calc:trim()

        APMBussin:emit(Events.APM_REPORT, self.collector.calc:apm())
        APMBussin:emit(Events.STATS, self.current_stats)
    end, self.opts.apm_report_period)
end

function MemoryReporter:clear()
    self.enabled = false
    self.collector:clear()
end

return MemoryReporter
