---@alias MotionFunction fun(arg: string): (MotionResult | nil, MotionFunction | nil)

---@class MotionResult
---@field done boolean
---@field consume boolean

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

local M = {}

function M.make_number(next)
    ---@type MotionFunction
    return function(arg)
        if tonumber(arg) == nil then
            return DONE_NO_CONSUME, next
        end
        return NO_DONE_CONSUME, nil
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
    local motions = ...
    ---@param arg string
    ---@return MotionResult | nil, MotionFunction | nil
    return function(arg)
        for _, motion in ipairs(motions) do
            local res, next = motion(arg)
            if res == nil then
                goto continue
            end

            if res.consume then
                return res, next
            end

            ::continue::
        end

        return nil, nil
    end
end

return M

