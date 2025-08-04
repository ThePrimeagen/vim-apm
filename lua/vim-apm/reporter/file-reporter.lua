local Stats = require("vim-apm.stats")
local Interval = require("vim-apm.interval")
local APMBussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")
local utils = require("vim-apm.utils")

---@class APMFileReporter : APMReporter
---@field path string
---@field enabled boolean
---@field collector APMStatsCollector
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

    local collector = Stats.StatsCollector.new(opts)

    return setmetatable({
        path = path,
        enabled = false,
        collector = collector,
        opts = opts,
        apms = {},
        apm_sum = 0,
    }, FileReporter)
end

---@param path string
---@return boolean
---@return APMStatsJson | nil
local function read_json_from_file(path)
    local ok, json = utils.read_file(path)
    return ok, json
end

function FileReporter:enable()
    if self.enabled then
        return
    end
    self.enabled = true
    self.collector:enable()

    Interval.interval(function()
        local ok, json = read_json_from_file(self.path)
        if not ok then
            json = Stats.empty_stats_json()
        end

        local merged = self.collector.stats:merge(json)

        local file = vim.loop.fs_open(self.path, "w", 493)
        local out_json = vim.fn.json_encode(merged)
        local ok2, res = pcall(vim.loop.fs_write, file, out_json)
        vim.loop.fs_close(file)

        APMBussin:emit(Events.STATS, merged)

        if not ok2 then
            error("vim-apm: error writing to file: " .. res)
        end
    end, self.opts.report_interval, "file-reporter")
end

function FileReporter:clear()
    self.enabled = false
    self.collector:clear()
end

return FileReporter
