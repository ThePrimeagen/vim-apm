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
        print("now", now, "then", self.insert_enter_time, "time", time)
        APMBussin:emit(INSERT_TIME, time)
        self.insert_time_event_emitted = true
    end
    self.insert_char_count = self.insert_char_count + 1
end


---@param key string
function APM:feedkey(key)
    if #key > 1 and string.byte(key, 1) == 128 and string.byte(key, 2) == 253 then
        return
        -- TODO: Revisit this later
        -- no idea how to handle this generally as i am sure there will be TONS of edge cases
        -- this all spawned from <80><fd>h after insert mode change
        --[[
        print("MULTI BYTE", key)
        local bytes = {}
        for i = 1, #key do
            bytes[i] = string.byte(key, i)
        end
        if bytes[1] == 128 and bytes[2] == 253 and bytes[3] == 104 then
            print("BAD BAD")
            return
        end
        --]]
    end

    if self.mode == NORMAL then
        self:_normal(key)
    elseif self.mode == INSERT then
        self:_insert(key)
    end
end

---@param _ string
---@param to string
function APM:handle_mode_changed(_, to)
    print("MODECHANGED", to)
    if to ~= NORMAL and to ~= VISUAL then
        self.motion:clear()
    end

    if self.mode == INSERT and to ~= INSERT then
        APMBussin:emit("insert_times", {
            insert_char_count = self.insert_char_count,
            insert_time = utils.now() - self.insert_enter_time,
        })
    end

    if to == INSERT then
        self.insert_enter_time = utils.now()
        print("NEW INSERT TIME", self.insert_enter_time)
        self.insert_time_event_emitted = false
        self.insert_char_count = 0
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

