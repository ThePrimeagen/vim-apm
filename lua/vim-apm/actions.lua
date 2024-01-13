local utils = require("vim-apm.utils")

---@class APMActions
---@field enabled boolean
---@field _ids number[]
---@field _on_key_id number | nil
local APMActions = {}
APMActions.__index = APMActions

function APMActions.new()

    return setmetatable({
        enabled = false,
        _on_key_id = nil,
        _ids = {},
    }, APMActions)
end

function APMActions:disable()
    if self.enabled == false then
        return
    end

    if self._on_key_id ~= nil then
        vim.on_key(nil, self._on_key_id)
        self._on_key_id = nil
    end
    utils.del_group_id()

    self._ids = {}
    self.enabled = false
end

function APMActions:enable()
    if self.enabled then
        return
    end

    self.enabled = true

    vim.api.nvim_create_autocmd('ModeChanged', {
        group = utils.vim_apm_group_id(),
        pattern = '*',

        ---@param event Event
        callback = function(event)
            local mode = utils.split(event.match, ":")
            -- self.apm:handle_mode_changed(mode[1], mode[2])
        end,
    })

    ---@param key string
    local on_key_id = vim.on_key(function(key)
        -- self.apm:feedkey(key)
    end, utils.vim_apm_group_id())

    self._on_key_id = on_key_id

    vim.api.nvim_create_autocmd("WinResized", {
        group = utils.vim_apm_group_id(),
        callback = function()
            --self.monitor:resize()
        end
    })

end

return APMActions
