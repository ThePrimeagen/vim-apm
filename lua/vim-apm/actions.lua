local utils = require("vim-apm.utils")
local APMBussin = require("vim-apm.bus")

local MODE = "mode"
local ON_KEY = "on_key"
local RESIZE = "resize"
local WRITE = "write"
local IDLE = "idle"

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

function APMActions:clear()
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

---@return boolean
function APMActions:enable()
    if self.enabled then
        return false
    end
    self.enabled = true

    local last_key_pressed = utils.now()
    local idle_evented = false

    local function idle_check()
        vim.defer_fn(function()
            if not self.enabled then
                return
            end

            local now = utils.now()
            if now - last_key_pressed > 2000 and not idle_evented then
                APMBussin:emit(IDLE)
                idle_evented = true
            end

            idle_check()
        end, 1000)
    end
    idle_check()

    vim.api.nvim_create_autocmd('ModeChanged', {
        group = utils.vim_apm_group_id(),
        pattern = '*',

        ---@param event Event
        callback = function(event)
            local mode = utils.split(event.match, ":")
            APMBussin:emit(MODE, mode)
        end,
    })

    ---@param key string
    local on_key_id = vim.on_key(function(key)
        last_key_pressed = utils.now()
        idle_evented = false

        APMBussin:emit(ON_KEY, key)
    end, utils.vim_apm_group_id())

    self._on_key_id = on_key_id

    vim.api.nvim_create_autocmd("WinResized", {
        group = utils.vim_apm_group_id(),
        callback = function()
            APMBussin:emit(RESIZE)
        end
    })

    vim.api.nvim_create_autocmd("BufWrite", {
        group = utils.vim_apm_group_id(),
        callback = function()
            APMBussin:emit(WRITE)
        end
    })

    return true
end

return {
    APMActions = APMActions,
    MODE = MODE,
    ON_KEY = ON_KEY,
    RESIZE = RESIZE,
    WRITE = WRITE,
}
