local Motion = require("vim-apm.motion")
local MotionTree = require("vim-apm.motion.motion_tree")
local APMBussin = require("vim-apm.bus")

local MOTION_ITEM = "motion"

local NORMAL = "n"
local INSERT = "i"
local COMMAND = "c"
local VISUAL = "v"
-- TODO fill out anything else?

---@class APM
---@field motion APMMotion
---@field mode string
local APM = {}
APM.__index = APM

function APM.new()
    local motion = Motion.Motion.new(MotionTree.all_motions)
    local self = setmetatable({
        motion = motion,
        mode = NORMAL,
    }, APM);
    return self
end

---@param key string
function APM:feedkey(key)
    -- TODO: handle mode changes
    local motion_item = self.motion:feedkey(key)

    if motion_item == nil then
        return
    end

    APMBussin:emit(MOTION_ITEM, motion_item)
end

---@param from string
---@param to string
function APM:handle_mode_changed(from, to)
    self.mode = to
end

return {
    APM = APM,
    Events = {
        MotionItem = MOTION_ITEM,
    }
}

