local motion_parser = require("vim-apm.reporter.motion_parser")

local Frequency = {}
Frequency.__index = Frequency

function Frequency.new(max)
    return setmetatable({
        motions = {},
        index = 1,
        max = max or 10,
    }, Frequency)
end

function Frequency:push(motion)
end

---@class APMAggregateMotionValue
---@field count number
---@field timings_total number

---@class APMCalculator
---@field motions table<string, APMAggregateMotionValue>
---@field commands table<string, APMAggregateMotionValue>
---@field write_count number
---@field insert_times number
---@field insert_times_count number
---@field buf_enter_count number
---@field mode_times table<string, number>
---@field state string
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
        mode_times = {},
        state = "",
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
    local sum = 0
    for _, timing in ipairs(motion.timings) do
        sum = sum + timing
    end

    self.motions[key] = self.motions[key] or {
        count = 1,
        timings_total = sum
    }
    self.motions[key].count = self.motions[key].count + 1
    self.motions[key].timings_total = self.motions[key].timings_total + sum
end

---@param mode string
function Calculator:mode(mode)
    self.mode_times[mode] = (self.mode_times[mode] or 0) + 1
end

function Calculator:buf_enter()
    self.buf_enter_count = self.buf_enter_count + 1
end

function Calculator:write()
    self.write_count = self.write_count + 1
end

---@param insert_time number
function Calculator:insert_time(insert_time)
    self.insert_times = self.insert_times + insert_time
    self.insert_times_count = self.insert_times_count + 1
end

--- this is a placeholder for when i have navigating / editing / idle states
--- as of now, it does nothing to the calculator
---@param state string
function Calculator:apm_state(state)
    self.state = state
end

return Calculator
