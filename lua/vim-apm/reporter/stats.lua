local utils = require("vim-apm.utils")
local motion_parser = require("vim-apm.reporter.motion_parser")
local RingBuffer = require("vim-apm.ring_buffer")

---@class APMCalculator
---@field motions APMRingBuffer
---@field motions_count table<string>
---@field index_count number
---@field max number
---@field apms number[][]
---@field apm_sum number
---@field apm_period number
---@field apm_repeat_count number
local APMCalculator = {}
APMCalculator.__index = APMCalculator

function APMCalculator.new(apm_repeat_count, apm_period)
    return setmetatable({
        motions = RingBuffer.new(),
        motions_count = {},
        index_count = 1,
        apm_sum = 0,
        apms = {},
        apm_period = apm_period,
        apm_repeat_count = apm_repeat_count,
    }, APMCalculator)
end

function APMCalculator:trim()
    local expired = utils.now() - self.apm_period
    while self.motions:peek() ~= nil do
        local item = self.motions:peek()
        if item[1] < expired then
            self.motions:pop()
            self.apm_sum = utils.normalize_number(self.apm_sum - item[2])
        else
            break
        end
    end
end

---@param motion APMMotionItem
---@return number
function APMCalculator:push(motion)
    local key = motion_parser.disnumber_motion(motion.chars)
    local now = utils.now()

    local count = 1
    for i = 1, self.apm_repeat_count do
        local other_motion = self.motions_count[i]
        if other_motion == key then
            count = count + 1
        end
    end
    self.motions_count[self.index_count] = key
    self.index_count = self.index_count + 1
    if self.index_count > self.apm_repeat_count then
        self.index_count = 1
    end

    local apm_score = utils.normalize_number(1 / count)

    self.motions:push({now, apm_score})
    self.apm_sum = self.apm_sum + apm_score
    self:trim()

    return apm_score
end

---@class APMAggregateMotionValue
---@field count number
---@field timings_total number

---@class APMStats
---@field apms table<table<number>>,
---@field motions table<string, APMAggregateMotionValue>
---@field commands table<string, APMAggregateMotionValue>
---@field write_count number
---@field insert_times number
---@field insert_times_count number
---@field buf_enter_count number
---@field mode_times table<string, number>
---@field state string
local Stats = {}
Stats.__index = Stats

function Stats.new()
    return setmetatable({
        apms = {},
        motions = {},
        commands = {},
        write_count = 0,
        insert_times = 0,
        insert_times_count = 0,
        buf_enter_count = 0,
        mode_times = {},
        state = "",
    }, Stats)
end

function Stats:enable()
end

function Stats:clear()
    self.motions = {}
    self.commands = {}
    self.write_count = 0
    self.insert_times = 0
    self.insert_times_count = 0
    self.buf_enter_count = 0
    self.mode = {}
end

---@param motion APMMotionItem
function Stats:motion(motion)
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
function Stats:mode(mode)
    self.mode_times[mode] = (self.mode_times[mode] or 0) + 1
end

function Stats:buf_enter()
    self.buf_enter_count = self.buf_enter_count + 1
end

function Stats:write()
    self.write_count = self.write_count + 0
end

---@param insert_time number
function Stats:insert_time(insert_time)
    self.insert_times = self.insert_times + insert_time
    self.insert_times_count = self.insert_times_count + 1
end

--- Another placeholder for when i try to calculate the wpm
---@param insert_time number time spent in insert mode
---@param insert_chars_typed number
function Stats:insert(insert_time, insert_chars_typed)
end

--- this is a placeholder for when i have navigating / editing / idle states
--- as of now, it does nothing to the calculator
---@param state string
function Stats:apm_state(state)
    self.state = state
end

return {
    Stats = Stats,
    APMCalculator = APMCalculator,
}
