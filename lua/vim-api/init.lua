---@class Event
---@field buf number
---@field event string

---@class VimApm
---@field namespace_id number
---@field group_id number
local VimApm = {}

VimApm.__index = VimApm

---@return VimApm
function VimApm.new()
    local self = setmetatable({}, VimApm)
    self.namespace_id = vim.api.nvim_create_namespace("vim-apm")
    self.group_id = vim.api.nvim_create_augroup("VimApm", {})
    return self
end

function VimApm:setup()
    vim.api.nvim_create_autocmd('ModeChanged', {
        group = self.group_id,
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
