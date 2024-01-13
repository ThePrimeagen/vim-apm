local utils = require("vim-apm.utils")
local Motion = require("vim-apm.motion")
local MotionTree = require("vim-apm.motion.motion_tree")
local APMBussin = require("vim-apm.bus")
local APMRingBuffer = require("vim-apm.ring_buffer")

local MOTION_ITEM = "motion"
local INSERT_TIME = "insert_time"


local NORMAL = "n"
local INSERT = "i"
local COMMAND = "c"
local VISUAL = "v"
-- TODO fill out anything else?

---@class APM
---@field motion APMMotion
---@field mode string
---@field motion_buffer APMRingBuffer
---@field insert_enter_time number
---@field insert_time_event_emitted boolean
local APM = {}
APM.__index = APM

function APM.new()
    local motion = Motion.Motion.new(MotionTree.all_motions)
    local self = setmetatable({
        motion = motion,
        mode = NORMAL,
        motion_buffer = APMRingBuffer.new(),
        insert_enter_time = 0,
        insert_time_event_emitted = true,
    }, APM);
    return self
end

function APM:clear()
    self.motion_buffer:clear()
end

function APM:enable()
    --- TODO: If i see any lag, here is a spot i could wait until idle before
    --- sending out events
    --[[
    APMBussin:listen(Actions.IDLE, function()
    end)

    APMBussin:listen(Actions.BUSY, function()
    end)
    --]]
end

---@param key string
function APM:_normal(key)
    -- TODO: handle mode changes
    local motion_item = self.motion:feedkey(key)

    if motion_item == nil then
        return
    end

    --- TODO: See note on enable
    APMBussin:emit(MOTION_ITEM, motion_item)
end

---@param _ string
function APM:_insert(_)
    if self.insert_time_event_emitted == false then
        local now = utils.now()
        local time = now - self.insert_enter_time
        APMBussin:emit(INSERT_TIME, time)
        self.insert_time_event_emitted = true
    end
end

---@param key string
function APM:feedkey(key)
    if self.mode == NORMAL then
        self:_normal(key)
    elseif self.mode == INSERT then
        self:_insert(key)
    end
end

---@param _ string
---@param to string
function APM:handle_mode_changed(_, to)
    if to ~= NORMAL then
        self.motion:clear()
    end

    if to == INSERT then
        self.insert_enter_time = utils.now()
        self.insert_time_event_emitted = false
    end

    self.mode = to
end

return {
    APM = APM,
    Events = {
        MotionItem = MOTION_ITEM,
        InsertTime = INSERT_TIME,
    }
}

