local utils = require("vim-apm.utils")
local APMBussin = require("vim-apm.bus")

local CALCULATED_MOTION = "cmotion"

---@class APMCalculator
---@field start_time number
---@field key_presses number
---@field motion_count number
local APMCalculator = {}
APMCalculator.__index = APMCalculator

function APMCalculator.new()
    local self = setmetatable({
        key_presses = 0,
        motion_count = 0,
        start_time = nil,
    }, APMCalculator)

    APMBussin:listen("motion", function(event)
        self:_calculate(event)
    end)

    return self
end

---@param motion APMMotion
function APMCalculator:_calculate(motion)
    if self.start_time == nil then
        self.start_time = utils.now()
    end

    self.motion_count = self.motion_count + 1
    self.key_presses = self.key_presses + #motion.chars

    local apm = self.key_presses / (
        (utils.now() - self.start_time) / 60000.0
    )

    APMBussin:emit(CALCULATED_MOTION, {
        apm = apm,
        chars = motion.chars,
    })
end

return {
    Calculator = APMCalculator,
    CALCULATED_MOTION = CALCULATED_MOTION,
}


