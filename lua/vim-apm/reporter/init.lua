local bussin = require("vim-apm.bus")
local Calc = require("vim-apm.calculator")

---@class APMReporter
---@field error boolean
---@field messages string[]
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

    --- @param motion APMCalculatedMotion
    bussin:listen(Calc.CALCULATED_MOTION, function(motion)
        if self.error then
            return
        end

        client:write(tostring(#motion.chars) .. ":" .. motion.chars)
        -- table.insert(self.messages, motion)
    end)

    return setmetatable(self, APMReporter)
end

return APMReporter
