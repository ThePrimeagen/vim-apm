local APMBussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")
local utils = require("vim-apm.utils")
local motion_parser = require("vim-apm.reporter.motion_parser")

local NORMAL = "n"
local INSERT = "i"
local VISUAL = "v"
local UNKNOWN = "untracked"
local SUPPORTED_MODES = {NORMAL, INSERT, VISUAL, UNKNOWN}

---@class APMStatsJson
---@field motions table<string, APMAggregateMotionValue>
---@field write_count number
---@field buf_enter_count number
---@field modes table<string, number>

---@class APMAggregateMotionValue
---@field count number

---@class APMStats
---@field motions table<string, APMAggregateMotionValue>
---@field write_count number
---@field buf_enter_count number
---@field modes table<string, number>
---@field last_mode string
---@field last_mode_start_time number
local Stats = {}
Stats.__index = Stats

local id = 0
---@return APMStats
function Stats.new()
    id = id + 1
    return setmetatable({
        motions = {},
        write_count = 0,
        id = id,
        buf_enter_count = 0,
        modes = {},
        last_mode = "n",
        last_mode_start_time = utils.now(),
    }, Stats)
end

---@param json APMStatsJson
---@return APMStatsJson
function Stats:merge(json)
    self:mode(self.last_mode)

    local out = {
        motions = {},
        modes = {},
        write_count = self.write_count + json.write_count,
        buf_enter_count = self.buf_enter_count + json.buf_enter_count,
    }

    for key, value in pairs(self.motions) do
        out.motions[key] = value
    end

    for key, value in pairs(json.motions) do
        local motion = out.motions[key]
        if motion then
            motion.count = motion.count + value.count
        else
            out.motions[key] = value
        end
    end

    for key, value in pairs(self.modes) do
        out.modes[key] = value
    end

    for key, value in pairs(json.modes) do
        out.modes[key] = (out.modes[key] or 0) + value
    end

    self:clear()

    return out
end

function Stats:clear()
    self.motions = {}
    self.modes = {}
    self.write_count = 0
    self.buf_enter_count = 0
end

---@param motion APMMotionItem
function Stats:motion(motion)
    local key = motion_parser.generate_motion_key(motion.chars)
    self.motions[key] = self.motions[key] or {
        count = 0,
    }
    self.motions[key].count = self.motions[key].count + 1
end

---@param mode string
function Stats:mode(mode)

    if mode ~= NORMAL and mode ~= INSERT and mode ~= VISUAL then
        mode = UNKNOWN
    end

    local now = utils.now()
    local time_in_last_mode = now - self.last_mode_start_time
    local last_mode = self.last_mode

    self.modes[last_mode] = (self.modes[last_mode] or 0) + time_in_last_mode
    self.last_mode_start_time = now
    self.last_mode = mode
end

function Stats:buf_enter()
    self.buf_enter_count = self.buf_enter_count + 1
end

function Stats:write()
    self.write_count = self.write_count + 1
end

---@returns APMStatsJson
function Stats:to_json()
    self:mode(self.last_mode)

    return {
        motions = self.motions,
        write_count = self.write_count,
        buf_enter_count = self.buf_enter_count,
        modes = self.modes,
    }
end

---@returns table<string, number>
function Stats:get_modes_and_reset_times()
    self:mode(self.last_mode)

    local out = self.modes
    self.modes = {}

    for _, mode in ipairs(SUPPORTED_MODES) do
        out[mode] = out[mode] or 0
        self.modes[mode] = 0
    end

    return out
end

local function empty_stats_json()
    return {
        motions = {},
        write_count = 0,
        buf_enter_count = 0,

        modes = {},
    }
end

---@class APMStatsCollector
---@field stats APMStats
local StatsCollector = {}
StatsCollector.__index = StatsCollector

---@return APMStatsCollector
function StatsCollector.new()
    local self = {
        stats = Stats.new(),
    }

    return setmetatable(self, StatsCollector)
end

function StatsCollector:enable()
    ---@param motion APMMotionItem
    APMBussin:listen(Events.MOTION, function(motion)
        self.stats:motion(motion)
    end)

    APMBussin:listen(Events.MODE_CHANGED, function(mode)
        self.stats:mode(mode[2])
    end)

    APMBussin:listen(Events.WRITE, function()
        self.stats:write()
    end)

    APMBussin:listen(Events.BUF_ENTER, function()
        self.stats:buf_enter()
    end)
end

function StatsCollector:clear()
    self.stats:clear()
end

return {
    empty_stats_json = empty_stats_json,
    StatsCollector = StatsCollector,
    Stats = Stats,
}
