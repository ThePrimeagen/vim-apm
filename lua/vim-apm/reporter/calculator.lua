local motion_parser = require("vim-apm.reporter.motion_parser")

---@class APMAggregateMotionValue
---@field count number
---@field

---@class APMCalculator
---@field motions table<string, >
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
    local parts = motion_parser.parse_motion_parts(motion.chars)

    self.motions
end

