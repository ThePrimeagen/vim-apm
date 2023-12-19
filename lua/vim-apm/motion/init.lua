---TODO: There is an optimization that can be done here
---Instead of having a large OrMotion key map, instead we could
---have a table lookup.  A KeyMapMotion

---@class MotionInterface
---@field test fun(self: MotionInterface, key: string): MotionResult | nil
---@field reset fun(self: MotionInterface): nil

---@class MotionResult
---@field done boolean
---@field result? {
---    type: "complex" | "consume" | "no-consume",
---    context: any
---}

---@param result MotionResult | nil
local function empty_no_consume(result)
    if result == nil then
        return false
    end

    if result.done == false then
        return false
    end

    if result.result.context ~= nil then
        return false
    end

    return true
end
---@class NumberMotion : MotionInterface
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

---@class KeyMotion : MotionInterface
---@field str string
local KeyMotion = { }
KeyMotion.__index = KeyMotion

---@return MotionInterface
function KeyMotion.new(str)
    if #str ~= 1 then
        error("KeyMotion only accepts a single character")
    end

    return setmetatable({
        str = str,
    }, KeyMotion)
end

---@param key string
---@return MotionResult | nil
function KeyMotion:test(key)
    if key == self.str then
        return {
            done = true,
            result = {
                type = "consume",
                context = self.str,
            }
        }
    end
    return nil
end

function KeyMotion:reset()
    self.index = 1
end

---@class OrMotion : MotionInterface
---@field sub_motions MotionInterface[]
---@field active_motion nil | MotionInterface
local OrMotion = {}
OrMotion.__index = OrMotion

function OrMotion.new(sub_motions)
    return setmetatable({
        sub_motions = sub_motions,
        active_motion = nil,
    }, OrMotion)
end

function OrMotion:test(key)
    if self.active_motion == nil then
        for _, motion in ipairs(self.sub_motions) do
            local result = motion:test(key)
            if result == nil or empty_no_consume(result) then
                goto continue
            elseif result.done then
                return result
            else
                self.active_motion = motion
                return result
            end
            ::continue::
        end
        return nil
    end

    local result = self.active_motion:test(key)
    if result == nil or result.done then
        self.active_motion = nil
    end
    return result
end

function OrMotion:reset()
    if self.active_motion ~= nil then
        self.active_motion:reset()
    end
    self.active_motion = nil
end

---@class AndMotion : MotionInterface
---@field sub_motions MotionInterface[]
---@field out any[]
---@field index number
local AndMotion = {}
AndMotion.__index = AndMotion

---@param sub_motions MotionInterface[]
function AndMotion.new(sub_motions)
    return setmetatable({
        sub_motions = sub_motions,
        out = {},
        index = 1,
    }, AndMotion)
end

function AndMotion:test(key)

    while true do
        local motion = self.sub_motions[self.index]
        local result = motion:test(key)

        if result == nil then
            self:reset()
            return nil
        end

        if result.done then
            if result.result.context ~= nil then
                table.insert(self.out, result.result.context)
            end

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
                        type = "consume",
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

function AndMotion:reset()
    if self.index <= #self.sub_motions then
        self.sub_motions[self.index]:reset()
    end
    self.index = 1
    self.out = {}
end


---@param letter string
---@return MotionInterface
local function create_command_motion(letter)
    return AndMotion.new({
        KeyMotion.new(letter),
        OrMotion.new({
            -- TODO: i need to do all the movement motions here
            -- such as dt<letter>
            AndMotion.new({
                NumberMotion.new(),
                KeyMotion.new(letter),
            }),
            KeyMotion.new(letter),
        })
    });
end

---@class VimMotion
---@field motions KeyMotion[]
local Motion = {}

Motion.__index = Motion

function Motion.new()
    return setmetatable({
        motions = {},
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

local M = {
    Motion = Motion,
    KeyMotion = KeyMotion,
    NumberMotion = NumberMotion,
    AndMotion = AndMotion,
    OrMotion = OrMotion,
}

return M


