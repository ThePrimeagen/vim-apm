local bussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")
local http = require("vim-apm.reporter.http.http")
local utils = require("vim-apm.utils")
local Interval = require("vim-apm.interval")
local Config = require("vim-apm.config")
local Stats = require("vim-apm.stats")

---@class UVTcp
---@field connect fun(self: UVTcp, host: string, port: number, callback: fun(err: string | nil): nil): nil
---@field write fun(self: UVTcp, data: string): nil
---@field close fun(self: UVTcp): nil

---@class AMPNetworkReporter : APMReporter
---@field apm_state "idle" | "busy"
---@field apm_state_time number
---@field messages {type: "motion" | "write" | "buf_enter", value: any}[]
---@field opts APMReporterOptions
---@field collector APMStatsCollector
local NetworkReporter = {}
NetworkReporter.__index = NetworkReporter

---@param opts APMReporterOptions | nil
---@return AMPNetworkReporter
function NetworkReporter.new(opts)
    opts = opts or {}
    assert(opts.token ~= nil, "token is required for network reporter")

    opts.uri = opts.uri or "127.0.0.1"
    opts.port = opts.port or 4000
    opts.network_mode = opts.network_mode or "immediate"

    local self = {
        messages = {},
        opts = opts,
        apm_state_time = utils.now(),
        apm_state = "busy",
        collector = Stats.StatsCollector.new(),
    }

    return setmetatable(self, NetworkReporter)
end

function NetworkReporter:enable()
    self.collector:enable()
    local function store_event(type)
        return function(value)
            self.messages[#self.messages + 1] = {
                type = type,
                value = value,
            }

            if self.opts.network_mode == "immediate" then
                self:_flush()
            end
        end
    end

    local function set_state(state)
        return function()
            local now = utils.now()
            local last_state = self.apm_state

            -- TODO: is there a possible to have a state change to the same previous state?
            table.insert(self.messages, {
                type = "apm_state_change",
                value = {
                    from = last_state,
                    time = utils.now() - self.apm_state_time,
                },
            })

            self.apm_state = state
            self.apm_state_time = now

            if state == "idle" or self.opts.network_mode == "immediate" then
                self:_flush()
            end
        end
    end

    self.interval_id = Interval.interval(function()
        table.insert(self.messages, {
            type = "mode_times",
            value = self.collector.stats:get_modes_and_reset_times(),
        })
        self:_flush()
    end, Config.modes_report_interval, "modes_report_interval")

    bussin:listen(Events.MOTION, store_event("motion"))
    bussin:listen(Events.WRITE, store_event("write"))
    bussin:listen(Events.BUF_ENTER, store_event("buf_enter"))
    bussin:listen(Events.IDLE_WORK, set_state("idle"))
    bussin:listen(Events.BUSY_WORK, set_state("busy"))
end

function NetworkReporter:_flush()
    for _, message in ipairs(self.messages) do
        pcall(
            http.make_request,
            self.opts.uri,
            self.opts.port,
            self.opts.token,
            message
        )
    end

    self.messages = {}
end

function NetworkReporter:clear()
    self.messages = {}
    Interval.cancel(self.interval_id)
    self.collector:clear()
end

return NetworkReporter
