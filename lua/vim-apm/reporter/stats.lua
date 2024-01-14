local utils = require("vim-apm.utils")
local motion_parser = require("vim-apm.reporter.motion_parser")

---@class APMCalculator
---@field motions table<number, string>
---@field index number
---@field max number
---@field apms number[][]
---@field apm_sum number
---@field apm_period number
local APMCalculator = {}
APMCalculator.__index = APMCalculator

function APMCalculator.new(max, apm_period)
    return setmetatable({
        motions = {},
        index = 1,
        max = max or 10,
        apm_sum = 0,
        apms = {},
        apm_period = apm_period,
    }, APMCalculator)
end

---@param motion APMMotionItem
function APMCalculator:push(motion)
    local key = motion_parser.disnumber_motion(motion.chars)
    local apm_score = 0

    if self.motions[self.index] then
        local count
        for _, other_motion in ipairs(self.motions) do
            if other_motion == key then
                count = count + 1
            end
        end

        apm_score = 1 / count
    end

    self.motions[self.index] = key
    self.index = self.index + 1
    if self.index > self.max then
        self.index = 1
    end

    local now = utils.now()
    local expired = now - self.apm_period
    local idx = 0
    for i, score in ipairs(self.apms) do
        if score[1] < expired then
            if idx == 0 then
                idx = i
            end
            self.apm_sum = self.apm_sum - score[2]
            self.apms[i] = nil
        end
    end

    self.apm_sum = self.apm_sum + apm_score
    if idx == 0 then
        table.insert(self.apms, apm_score)
    else
        self.apms[idx] = {now, apm_score}
    end
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
    self.write_count = self.write_count + 1
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
