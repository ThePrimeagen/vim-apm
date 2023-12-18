---@class MotionInterface
---@field test fun(self: MotionInterface, key: string): MotionResult | nil
---@field reset fun(self: MotionInterface): nil

---@class MotionResult
---@field done boolean
---@field result? {
---    type: "complex" | "fixed-motion" | "no-consume",
---    context: any
---}

local NumberMotion = {}
NumberMotion.__index = NumberMotion

function NumberMotion.new()
    return setmetatable({
        numbers = ""
    }, NumberMotion)
end

---@return MotionResult | nil
function NumberMotion:test(key)
    if key:match("%d") then
        self.numbers = self.numbers .. key
        return {
            done = false,
        }
    end

    local number = tonumber(self.numbers)
    self.numbers = ""
    return {
        done = true,
        result = {
            type = "no-consume",
            context = number,
        }
    }
end

function NumberMotion:reset()
    self.numbers = ""
end

---@class KeyMotion
---@field str string
---@field index number
local KeyMotion = { }
KeyMotion.__index = KeyMotion

---@return MotionInterface
function KeyMotion.new(str)
    return setmetatable({
        str = str,
        index = 1,
    }, KeyMotion)
end

---@param key string
---@return MotionResult | nil
function KeyMotion:test(key)
    if self.str:sub(self.index, self.index) == key then
        self.index = self.index + 1

        if self.index > #self.str then
            self.index = 1
            return { done = true, result = {
                type = "fixed-motion",
                context = self.str,
            }}
        end

        return {
            done = false
        }
    end

    self.index = 1
    return nil
end

function KeyMotion:reset()
    self.index = 1
end

---@class ComplexMotion
---@field sub_motions MotionInterface[]
---@field out any[]
---@field index number
local ComplexMotion = {}
ComplexMotion.__index = ComplexMotion

---@param sub_motions MotionInterface[]
function ComplexMotion.new(sub_motions)
    return setmetatable({
        sub_motions = sub_motions,
        out = {},
        index = 1,
    }, ComplexMotion)
end

function ComplexMotion:test(key)

    while true do
        local motion = self.sub_motions[self.index]
        local result = motion:test(key)

        if result == nil then
            return nil
        end

        if result.done then
            table.insert(self.out, result.result.context)
            self.index = self.index + 1

            if result.result.type == "no-consume" then
                goto continue
            end

            if self.index > #self.sub_motions then
                local out = self.out
                self:reset()
                return {
                    done = true,
                    result = {
                        type = "complex",
                        context = out,
                    }
                }
            end
        end

        if result.done == false then
            break
        end

        -- I am going to regret making these goto statements for fun
        ::continue::;
    end

    return {
        done = false,
    }
end

function ComplexMotion:reset()
    for _, motion in ipairs(self.sub_motions) do
        motion:reset()
    end
    self.index = 1
    self.out = {}
end


local key_motions = {
    KeyMotion.new("x"),
    KeyMotion.new("X"),
    KeyMotion.new("s"),
    KeyMotion.new("S"),
    ComplexMotion.new({
        NumberMotion.new(),
        KeyMotion.new("gg"),
    }),
}

---@class VimMotion
---@field motions KeyMotion[]
local Motion = {}

Motion.__index = Motion

function Motion.new()
    return setmetatable({
        motions = key_motions,
    }, Motion)
end

---@param key string
---@return MotionResult | nil
function Motion:feedkey(key)
    local out = {}
    for _, motion in ipairs(self.motions) do
        local result = motion:test(key)
        if result == nil then
            goto continue
        end

        if result.done then
            return result.result
        end

        table.insert(out, motion)

        ::continue::
    end

    if #out == 0 then
        self.motions = key_motions
    else
        self.motions = out
    end

    return nil
end

function Motion:reset()
    error("please implement me daddy")
    vim.schedule(function()
    end)
end

return Motion
