local Events = require("vim-apm.event_names")
local utils = require("vim-apm.utils")
local Motion = require("vim-apm.motion")
local MotionTree = require("vim-apm.motion.motion_tree")
local APMBussin = require("vim-apm.bus")
local APMRingBuffer = require("vim-apm.ring_buffer")

local NORMAL = "n"
-- local OPERATIONAL_PENDING_MODE = "no"
local INSERT = "i"
local COMMAND = "c"
-- local VISUAL = "v"

---@class APMInsertTimeEvent
---@field insert_char_count number
---@field insert_time number

---@class APM
---@field motion APMMotion
---@field mode string
---@field motion_buffer APMRingBuffer
---@field insert_enter_time number
---@field insert_char_count number
---@field insert_time_event_emitted boolean
local APM = {}
APM.__index = APM

function APM.new()
    local motion = Motion.Motion.new(MotionTree.all_motions)
    local self = setmetatable({
        motion = motion,
        mode = NORMAL,
        motion_buffer = APMRingBuffer.new(),
        insert_char_count = 0,
        insert_enter_time = 0,
        insert_time_event_emitted = true,
    }, APM)
    return self
end

function APM:enable()
    APMBussin:listen(Events.MODE_CHANGED, function(mode)
        self:handle_mode_changed(mode[1], mode[2])
    end)

    APMBussin:listen(Events.ON_KEY, function(key)
        self:feedkey(key)
    end)
end

---@param key string
function APM:_normal(key)
    local motion_item = self.motion:feedkey(key)

    if motion_item == nil then
        return
    end

    APMBussin:emit(Events.MOTION, motion_item)
end

---@param _ string
function APM:_insert(_)
    if self.insert_time_event_emitted == false then
        local now = utils.now()
        local time = now - self.insert_enter_time
        APMBussin:emit(Events.INSERT_TO_TIME, time)
        self.insert_time_event_emitted = true
    end
    self.insert_char_count = self.insert_char_count + 1
end

---@param key string
function APM:feedkey(key)
    if self.mode == INSERT then
        self:_insert(key)
    elseif self.mode ~= COMMAND then
        self:_normal(key)
    end
end

---@param from string
---@param to string
function APM:handle_mode_changed(from, to)
    if from == INSERT and to ~= INSERT then
        self.motion:clear()
    end

    if self.mode == INSERT and to ~= INSERT then
        APMBussin:emit(Events.INSERT_IN_TIME, {
            insert_char_count = self.insert_char_count,
            insert_time = utils.now() - self.insert_enter_time,
        })
    end

    if to == INSERT then
        self.insert_enter_time = utils.now()
        self.insert_time_event_emitted = false
        self.insert_char_count = 0
    end

    self.mode = to
end

return APM
