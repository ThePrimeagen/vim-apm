local motion_parser = require("vim-apm.reporter.motion_parser")

---@class APMAggregateMotionValue
---@field count number
---@field timings_total number[]

---@class APMCalculator
---@field motions table<string, APMAggregateMotionValue>
---@field commands table<string, APMAggregateMotionValue>
---@field write_count number
---@field insert_times number
---@field insert_times_count number
---@field buf_enter_count number
---@field mode table<string, number>
local Calculator = {}
Calculator.__index = Calculator

function Calculator.new()
    return setmetatable({
        motions = {},
        commands = {},
        write_count = 0,
        insert_times = 0,
        insert_times_count = 0,
        buf_enter_count = 0,
        mode = {},
    }, Calculator)
end

function Calculator:enable()
end

function Calculator:clear()
    self.motions = {}
    self.commands = {}
    self.write_count = 0
    self.insert_times = 0
    self.insert_times_count = 0
    self.buf_enter_count = 0
    self.mode = {}
end

---@param motion APMMotionItem
function Calculator:motion(motion)
    local key = motion_parser.generate_motion_key(motion.chars)
    local parts = motion_parser.parse_motion_parts(motion.chars)

    self.motions
end

