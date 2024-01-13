local Motion = require("vim-apm.motion")
local MotionTree = require("vim-apm.motion.motion_tree")
local APMBussin = require("vim-apm.bus")
local APMRingBuffer = require("vim-apm.ring_buffer")

local MOTION_ITEM = "motion"

local NORMAL = "n"
local INSERT = "i"
local COMMAND = "c"
local VISUAL = "v"
-- TODO fill out anything else?

---@class APM
---@field motion APMMotion
---@field mode string
---@field motion_buffer APMRingBuffer
---@field motions_to_emit APMMotionItem[]
local APM = {}
APM.__index = APM

function APM.new()
    local motion = Motion.Motion.new(MotionTree.all_motions)
    local self = setmetatable({
        motion = motion,
        mode = NORMAL,
        motion_buffer = APMRingBuffer.new(),
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
    local Actions = require("vim-apm.actions")
    APMBussin:listen(Actions.IDLE, function()
    end)

    APMBussin:listen(Actions.BUSY, function()
    end)
    --]]
end

---@param key string
function APM:feedkey(key)
    if self.mode ~= NORMAL then
        return
    end

    -- TODO: handle mode changes
    local motion_item = self.motion:feedkey(key)

    if motion_item == nil then
        return
    end

    --- TODO: See note on enable
    APMBussin:emit(MOTION_ITEM, motion_item)
end

---@param _ string
---@param to string
function APM:handle_mode_changed(_, to)
    if to ~= "n" then
        self.motion:clear()
    end

    self.mode = to
end

return {
    APM = APM,
    Events = {
        MotionItem = MOTION_ITEM,
    }
}

