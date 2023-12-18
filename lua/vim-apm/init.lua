local utils = require("vim-apm.utils")
local float = require("vim-apm.ui.float")
local State = require("vim-apm.state")
local Emitter = require("vim-apm.state-emitter")

---@class Event
---@field buf number
---@field event string

---@class VimApm
---@field monitor ApmFloat
---@field state ApmState
---@field emitter ApmStateEmitter
local VimApm = {}

VimApm.__index = VimApm

---@return VimApm
function VimApm.new()
    local state = State.new()
    local emitter = Emitter.new()

    emitter:listener(state)

    local self = setmetatable({
        state = state,
        emitter = emitter,
        monitor = float.new(state),
    }, VimApm)
    return self
end

function VimApm:setup()

    print("setup");
    vim.api.nvim_create_autocmd('ModeChanged', {
        group = utils.vim_apm_group_id,
        pattern = '*',

        ---@param event Event
        callback = function(event)
            local mode = utils.split(event.match, ":")
            self.emitter:handle_mode_changed(mode[1], mode[2])
        end,
    })

    ---@param key string
    vim.on_key(function(key)
        self.emitter:handle_key(key)
    end)

    vim.api.nvim_create_autocmd("WinResized", {
        group = utils.vim_apm_group_id,
        callback = function()
            self.monitor:resize()
        end
    })

end

return VimApm.new()
