local utils = require("vim-api.utils")

---@class Event
---@field buf number
---@field event string

---@class VimApm
local VimApm = {}

VimApm.__index = VimApm

---@return VimApm
function VimApm.new()
    local self = setmetatable({}, VimApm)
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
end

return VimApm.new()
