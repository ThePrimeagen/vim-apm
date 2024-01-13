local utils = require("vim-apm.utils")
local APM = require("vim-apm.apm")
local APMCalculator = require("vim-apm.calculator")
local float = require("vim-apm.ui.float")
local Reporter = require("vim-apm.reporter")

---@class Event
---@field buf number
---@field match string

---@class VimApm
---@field apm APM
---@field calc APMCalculator
---@field monitor APMFloat
---@field reporter APMReporter
local VimApm = {}

VimApm.__index = VimApm

---@return VimApm
function VimApm.new()
    local apm = APM.APM.new()
    local calculator = APMCalculator.Calculator.new()
    local monitor = float.new()
    local reporter = Reporter.new()

    local self = setmetatable({
        apm = apm,
        calculator = calculator,
        monitor = monitor,
        reporter = reporter,
    }, VimApm)

    return self
end

function VimApm:setup()

    vim.api.nvim_create_autocmd('ModeChanged', {
        group = utils.vim_apm_group_id,
        pattern = '*',

        ---@param event Event
        callback = function(event)
            local mode = utils.split(event.match, ":")
            self.apm:handle_mode_changed(mode[1], mode[2])
        end,
    })

    local count = 0
    ---@param key string
    vim.on_key(function(key)
        count = count + 1
        self.apm:feedkey(key)
    end)

    vim.api.nvim_create_autocmd("WinResized", {
        group = utils.vim_apm_group_id,
        callback = function()
            self.monitor:resize()
        end
    })

end

function VimApm:toggle_monitor()
    self.monitor:toggle()
end

return VimApm.new()
