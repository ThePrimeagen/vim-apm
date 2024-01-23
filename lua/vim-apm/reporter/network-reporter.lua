local network_utils = require("vim-apm.reporter.network-utils")
local bussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")

local NetworkReporter = {}
NetworkReporter.__index = NetworkReporter

--- TODO: Think about reconnecting / understanding the current socket connection state
function NetworkReporter.new()
    local self = {
        error = false,
        messages = {}
    }

    local uv = vim.loop
    local client = uv.new_tcp()
    client:connect("127.0.0.1", 6112, function (err)
        if err ~= nil then
            error("vim-apm failed to connect to the APM server: " .. err)
            self.error = true
            return
        end
    end)

    --- @param motion APMMotionItem
    bussin:listen(Events.MOTION, function(motion)
        if self.error then
            return
        end

        local packet = network_utils.encode_motion(motion)
        client:write(packet)
        -- table.insert(self.messages, motion)
    end)

    return setmetatable(self, NetworkReporter)
end

function NetworkReporter:enable()
end

function NetworkReporter:clear()
end

return NetworkReporter
