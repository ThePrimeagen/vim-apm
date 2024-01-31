--- TODO: I would like to see a more robust socket solution here.  Right now
--- its all inlined, but a separate IoC method could be nice for both testing
--- and for production
--
local network_utils = require("vim-apm.reporter.network-utils")
local bussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")

---@class UVTcp
---@field connect fun(self: UVTcp, host: string, port: number, callback: fun(err: string | nil): nil): nil
---@field write fun(self: UVTcp, data: string): nil
---@field close fun(self: UVTcp): nil

---@class AMPNetworkReporter : APMReporter
---@field state "stopped" | "connecting" | "connected" | "error"
---@field apm_state "idle" | "busy"
---@field messages {type: "motion" | "write" | "buf_enter", value: any}[]
---@field opts APMReporterOptions
---@field client UVTcp | nil
local NetworkReporter = {}
NetworkReporter.__index = NetworkReporter

---@param opts APMReporterOptions | nil
---@return AMPNetworkReporter
function NetworkReporter.new(opts)
    opts = opts or {}
    opts.uri = opts.uri or "127.0.0.1"
    opts.port = opts.port or 6112

    local self = {
        state = "stopped",
        messages = {},
        opts = opts,

        client = nil,
    }

    return setmetatable(self, NetworkReporter)
end

function NetworkReporter:enable()
    local uv = vim.loop
    local client = uv.new_tcp()

    self.client = client
    self.state = "connecting"

    client:connect(self.opts.uri, self.opts.port, function(err)
        if self.state == "stopped" and err == nil then
            -- some how we have connected, but was stopped before this callback but the close call must not have worked
            -- so close again!
            pcall(self.client.close, self.client)
            return
        end
        if err ~= nil then
            self.state = "error"
            error("vim-apm failed to connect to the APM server: " .. err)
        else
            self.state = "connected"
        end
    end)

    local function store_event(type)
        return function(value)
            if self.state == "error" or self.state == "stopped" then
                return
            end

            self.messages[#self.messages + 1] = {
                type = type,
                value = value,
            }
        end
    end

    local function set_state(state)
        return function()
            self.apm_state = state
            if state == "idle" then
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
    if self.state ~= "connected" then
        return
    end

    if self.apm_state == "busy" then
        return
    end

    local to_write = ""
    for _, message in ipairs(self.messages) do
        if message.type == "motion" then
            to_write = to_write .. network_utils.encode_motion(message.value)
        end
    end

    if to_write ~= "" then
        self.client:write(to_write)
    end
end

function NetworkReporter:clear()
    self.messages = {}

    --- Note: we never unhook apm bussin, that is expected at the top level clear call.
    if self.state == "stopped" or self.state == "error" then
        return
    end

    pcall(self.client.close, self.client)
    self.client = nil
    self.state = "stopped"
end

return NetworkReporter
