local utils = require("vim-apm.utils")
local APM = require("vim-apm.apm")
-- local float = require("vim-apm.ui.float")

---@class Event
---@field buf number
---@field match string

---@class VimApm
---@field apm APM
---@field monitor APMFloat
local VimApm = {}

VimApm.__index = VimApm

---@return VimApm
function VimApm.new()
    local self = setmetatable({
        apm = APM.APM.new(),
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

    ---@param key string
    vim.on_key(function(key)
        self.apm:feedkey(key)
    end)

    vim.api.nvim_create_autocmd("WinResized", {
        group = utils.vim_apm_group_id,
        callback = function()
            self.monitor:resize()
        end
    })

end

return VimApm.new()
