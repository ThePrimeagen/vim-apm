local utils = require("vim-apm.utils")
local APM = require("vim-apm.apm")
local APMCalculator = require("vim-apm.calculator")
local float = require("vim-apm.ui.float")
local Reporter = require("vim-apm.reporter")
local Actions = require("vim-apm.actions")

---@class Event
---@field buf number
---@field match string

---@class VimApm
---@field apm APM
---@field calc APMCalculator
---@field monitor APMFloat
---@field actions APMActions
---@field reporter APMReporter
local VimApm = {}

VimApm.__index = VimApm

---@return VimApm
function VimApm.new()
    local apm = APM.APM.new()

    local calculator = APMCalculator.Calculator.new()
    local monitor = float.new()
    local reporter = Reporter.new()
    local actions = Actions.new()

    local self = setmetatable({
        apm = apm,
        calculator = calculator,
        monitor = monitor,
        reporter = reporter,
        actions = actions,
    }, VimApm)

    return self
end

function VimApm:setup()
    self.actions:enable()
end

function VimApm:toggle_monitor()
    self.monitor:toggle()
end

return VimApm.new()
