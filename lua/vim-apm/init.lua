VimAPMRequired = true

local Events = require("vim-apm.event_names")
local APM = require("vim-apm.apm")
local float = require("vim-apm.ui.float")
local Reporter = require("vim-apm.reporter")
local Actions = require("vim-apm.actions")
local APMBussin = require("vim-apm.bus")


---@class APMOptions
---@field reporter? APMReporterOptions

---@class Event
---@field buf number
---@field match string

---@class VimApm
---@field apm APM | nil
---@field monitor APMFloat | nil
---@field actions APMActions | nil
---@field reporter APMReporter | nil
local VimApm = {}

VimApm.__index = VimApm

---@return VimApm
function VimApm.new()

    local self = setmetatable({
        enabled = false,
    }, VimApm)

    return self
end

---@param opts APMOptions
function VimApm:setup(opts)
    opts = vim.tbl_extend("force", {}, {
        reporter = Reporter.default_options(),
    }, opts)

    self:clear()
    self.enabled = true

    self.reporter = Reporter.create_reporter(opts.reporter)
    self.reporter:enable()

    self.apm = APM.new()
    self.monitor = float.new()
    self.actions = Actions.new()

    APMBussin:listen(Events.MODE_CHANGED, function(mode)
        self.apm:handle_mode_changed(mode[1], mode[2])
    end)

    APMBussin:listen(Events.ON_KEY, function(key)
        self.apm:feedkey(key)
    end)

    APMBussin:listen(Events.RESIZE, function()
        self.monitor:resize()
    end)

end

function VimApm:clear()
    APMBussin:clear()
    self.reporter = nil
    self.apm = nil
    self.monitor = nil
    self.actions = nil
    self.enabled = false
end

function VimApm:toggle_monitor()
    self.monitor:toggle()
end

return VimApm.new()
