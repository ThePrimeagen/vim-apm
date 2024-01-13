VimAPMRequired = true

local APM = require("vim-apm.apm")
local float = require("vim-apm.ui.float")
local Reporter = require("vim-apm.reporter")
local ActionsModule = require("vim-apm.actions")
local APMBussin = require("vim-apm.bus")

local Actions = ActionsModule.APMActions

---@class APMOptions
---@field reporter? APMReporterOptions

---@class Event
---@field buf number
---@field match string

---@class VimApm
---@field apm APM
---@field monitor APMFloat
---@field actions APMActions
---@field reporter APMReporter | nil
local VimApm = {}

VimApm.__index = VimApm

---@return VimApm
function VimApm.new()
    local apm = APM.APM.new()

    local monitor = float.new()
    local actions = Actions.new()

    local self = setmetatable({
        apm = apm,
        monitor = monitor,
        actions = actions,
    }, VimApm)

    return self
end

---@param opts APMOptions
function VimApm:setup(opts)
    opts = vim.tbl_extend("force", {}, {
        reporter = Reporter.default_options(),
    }, opts)

    self:clear()

    self.actions:enable()
    self.monitor:enable()
    self.apm:enable()

    self.reporter = Reporter.create_reporter(opts.reporter)
    self.reporter:enable()

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
    self.apm:clear()

    if self.reporter ~= nil then
        self.reporter:clear()
        self.reporter = nil
    end
end

function VimApm:toggle_monitor()
    self.monitor:toggle()
end

return VimApm.new()
