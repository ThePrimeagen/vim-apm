
---@class ApmState
---
local ApmState = {}
ApmState.__index = ApmState

function ApmState.new()
    return setmetatable({
    }, ApmState)
end

return ApmState


