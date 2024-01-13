local motion_parser = require("vim-apm.reporter.motion_parser")

---@class APMCalculator
---@field motions = {}
---@field commands = {}
---@field write_count = {}
---@field insert_times = {}
---@field buf_enter_count = {}
local Calculator = {}
Calculator.__index = Calculator

function Calculator.new()
    return setmetatable({
        motions = {},
        commands = {},
        write_count = {},
        insert_times = {},
        buf_enter_count = {},
    }, Calculator)
end

---@param motion APMMotionItem
function Calculator:motion(motion)
    local key = motion_parser.disnumber_motion(motion.chars)
    self.motions
end

