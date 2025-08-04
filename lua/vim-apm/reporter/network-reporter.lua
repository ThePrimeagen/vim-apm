local bussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")
local http = require("vim-apm.reporter.http.http")

---@class UVTcp
---@field connect fun(self: UVTcp, host: string, port: number, callback: fun(err: string | nil): nil): nil
---@field write fun(self: UVTcp, data: string): nil
---@field close fun(self: UVTcp): nil

---@class AMPNetworkReporter : APMReporter
---@field state "stopped" | "connecting" | "connected" | "error"
---@field apm_state "idle" | "busy"
---@field messages {type: "motion" | "write" | "buf_enter", value: any}[]
---@field opts APMReporterOptions
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
        state = "stopped",
        messages = {},
        opts = opts,
    }

    return setmetatable(self, NetworkReporter)
end

function NetworkReporter:enable()
    local function store_event(type)
        return function(value)
            if self.state == "error" or self.state == "stopped" then
                return
            end

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
            self.apm_state = state
            if state == "idle" and self.opts.network_mode == "batch" then
                self:_flush()
            end
        end
    end

    bussin:listen(Events.MOTION, store_event("motion"))
    bussin:listen(Events.WRITE, store_event("write"))
    bussin:listen(Events.BUF_ENTER, store_event("buf_enter"))
    bussin:listen(Events.IDLE_WORK, set_state("idle"))
    bussin:listen(Events.BUSY_WORK, set_state("busy"))
end

function NetworkReporter:_flush()
    http.make_request(self.opts.uri, self.opts.port, self.opts.token, self.messages)
    self.messages = {}
end

function NetworkReporter:clear()
    self.messages = {}
end

return NetworkReporter
