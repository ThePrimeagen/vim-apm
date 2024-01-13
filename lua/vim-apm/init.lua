VimAPMRequired = true

local APM = require("vim-apm.apm")
local APMCalculator = require("vim-apm.calculator")
local float = require("vim-apm.ui.float")
local Reporter = require("vim-apm.reporter")
local ActionsModule = require("vim-apm.actions")
local APMBussin = require("vim-apm.bus")

local Actions = ActionsModule.APMActions

---@class APMOptions

---@class Event
---@field buf number
---@field match string

---@class VimApm
---@field apm APM
---@field calculator APMCalculator
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

---@param opts APMOptions
function VimApm:setup(opts)
    self:clear()

    self.actions:enable()
    self.calculator:enable()
    self.monitor:enable()

    APMBussin:listen(ActionsModule.MODE, function(mode)
        self.apm:handle_mode_changed(mode[1], mode[2])
    end)
    APMBussin:listen(ActionsModule.ON_KEY, function(key)
        self.apm:feedkey(key)
    end)
    APMBussin:listen(ActionsModule.RESIZE, function()
        self.monitor:resize()
    end)
end

function VimApm:clear()
    APMBussin:clear()
    self.monitor:close()
    self.actions:clear()
    self.calculator:clear()
end

function VimApm:toggle_monitor()
    self.monitor:toggle()
end

return VimApm.new()
