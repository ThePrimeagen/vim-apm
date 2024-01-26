---@alias MotionFunction fun(arg: string): (MotionResult | nil, MotionFunction | nil)

---@class MotionResult
---@field done boolean
---@field consume boolean
---

local DONE_CONSUME = {
    done = true,
    consume = true,
}

local DONE_NO_CONSUME = {
    done = true,
    consume = false,
}

local NO_DONE_CONSUME = {
    done = false,
    consume = true,
}

local M = {
    State = {
        DONE_CONSUME = DONE_CONSUME,
        DONE_NO_CONSUME = DONE_NO_CONSUME,
        NO_DONE_CONSUME = NO_DONE_CONSUME,
    },
}

function M.make_number(next)
    ---@type MotionFunction
    return function(arg)
        if tonumber(arg) == nil then
            return DONE_NO_CONSUME, next
        end
        return NO_DONE_CONSUME, nil
    end
end

function M.make_any_key(next)
    ---@param _ string
    ---@return MotionResult | nil, MotionFunction | nil
    return function(_)
        return DONE_CONSUME, next
    end
end

function M.make_key(key, next)
    ---@param arg string
    ---@return MotionResult | nil, MotionFunction | nil
    return function(arg)
        if arg == key then
            return DONE_CONSUME, next
        end
        return nil, nil
    end
end

function M.make_or(...)
    local motions = {}
    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        table.insert(motions, fn)
    end

    ---@param arg string
    ---@return MotionResult | nil, MotionFunction | nil
    return function(arg)
        for _, motion in ipairs(motions) do
            local res, next = motion(arg)
            if res ~= nil then
                return res, next
            end
        end

        return nil, nil
    end
end

return M
