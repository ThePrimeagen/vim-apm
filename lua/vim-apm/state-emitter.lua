
---@class ApmStateEmitterItem
---@field mode string
---@field key? string

---DO YOU EVEN JAVA BRO?
---@class ApmStateEmitterListener
---@field on_state_change? fun(ApmStateItem): nil

---@class ApmStateEmitter
---@field listeners ApmStateEmitterListener[]
---@field mode "n" | "i" | "c" | "v"
local ApmStateEmitter = {}
ApmStateEmitter.__index = ApmStateEmitter

function ApmStateEmitter.new()
    return setmetatable({
        listeners = {},
        mode = "n",
    }, ApmStateEmitter)
end

function ApmStateEmitter:handle_key(key)
    self:_emit(key)
end

function ApmStateEmitter:handle_mode_changed(from, to)
    self.mode = to
    self:_emit(nil)
end

---@param listener ApmStateEmitterListener
function ApmStateEmitter:listener(listener)
    table.insert(self.listeners, listener)
end

---@param key string | nil
function ApmStateEmitter:_emit(key)
    local state = {
        mode = self.mode,
        key = key,
    }
    for _, listener in ipairs(self.listeners) do
        if listener.on_state_change then
            listener.on_state_change(state)
        end
    end
end

return ApmStateEmitter


