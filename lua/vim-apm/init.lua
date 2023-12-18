local utils = require("vim-apm.utils")
local float = require("vim-apm.ui.float")
local State = require("vim-apm.state")

---@class Event
---@field buf number
---@field event string

---@class VimApm
---@field monitor ApmFloat
---@field state ApmFloat
local VimApm = {}

VimApm.__index = VimApm

---@return VimApm
function VimApm.new()
    local state = State.new()
    local self = setmetatable({
        state = state,
        monitor = float.new(state),
    }, VimApm)
    return self
end

function VimApm:setup()
    vim.api.nvim_create_autocmd('ModeChanged', {
        group = utils.vim_apm_group_id,
        pattern = '*',

        ---@param event Event
        callback = function(event)
        end,
    })

    ---@param key string
    vim.on_key(function(key)
    end)

    vim.api.nvim_create_autocmd("WinResized", {
        group = utils.vim_apm_group_id,
        callback = function()
            self.monitor:resize()
        end
    })

end

return VimApm.new()
