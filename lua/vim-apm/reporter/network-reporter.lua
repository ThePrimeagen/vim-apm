local network_utils = require("vim-apm.reporter.network-utils")
local bussin = require("vim-apm.bus")
local Apm = require("vim-apm.apm")
local MOTION = Apm.Events.MotionItem

local APMReporter = {}
APMReporter.__index = APMReporter

--- TODO: Think about reconnecting / understanding the current socket connection state
function APMReporter.new()
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
    bussin:listen(MOTION, function(motion)
        if self.error then
            return
        end

        local packet = network_utils.encode_motion(motion)
        client:write(packet)
        -- table.insert(self.messages, motion)
    end)

    return setmetatable(self, APMReporter)
end

return APMReporter

