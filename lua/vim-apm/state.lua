local single_key_commands = {
    "x",
    "X",
    "s",
    "S",
    "G",
}

---@class ApmStateItem
---@field type "motion" | "time_to_insert"
---@field context any

---@class ApmStateListener
---@field on_state_change? fun(state: ApmStateItem): nil

---@class ApmState
---@field mode "n" | "i" | "c" | "v"
---@field listeners ApmStateListener[]
local ApmState = {}

ApmState.__index = ApmState

function ApmState.new()
    return setmetatable({
        mode = "n",
        listeners = {},
    }, ApmState)
end

---@param state ApmStateEmitterItem
function ApmState:on_state_change(state)
    if state.key == nil then
        self.mode = state.mode
        return
    end

    if state.mode == "n" then
    end
end

---@param listener ApmStateListener
function ApmState:listen(listener)
    table.insert(self.listeners, listener)
end

function ApmState:_emit()
    -- TODO: huh?
end
