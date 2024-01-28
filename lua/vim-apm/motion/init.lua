local utils = require("vim-apm.utils")

---The motion item that represents a vim motion will contain N - 1 timings.
---The timings will be relative to the first keypress and in ms
---@class APMMotionItem
---@field chars string
---@field timings number[]

local function get_char(item)
    return item.chars
end

---@class APMMotion
---@field head MotionFunction
---@field curr MotionFunction | nil
---@field chars string
---@field timings number[]
local Motion = {}
Motion.__index = Motion

function Motion.new(head)
    return setmetatable({
        head = head,
        curr = nil,
        chars = "",
        timings = {},
    }, Motion)
end

function Motion:clear()
    if self.curr == nil then
        return
    end

    self.curr = nil
    self.chars = ""
    self.timings = {}
end

---@param key string
---@return APMMotionItem | nil
function Motion:feedkey(key)
    if self.curr == nil then
        self.curr = self.head
        self.timings = {}
        self.chars = ""
    end

    while true do
        if self.curr == nil then
            error("infalible: curr is nil")
        end

        -- how the hell do i convert that?

        local res, next = self.curr(key)

        if res == nil then
            self.curr = nil
            return nil
        end

        if res.consume then
            self.chars = self.chars .. key
            table.insert(self.timings, utils.now())
        end

        if res.done and next == nil then
            self.curr = nil
            -- that should be good...?
            return self:create_motion_item()
        end

        if res.done then
            self.curr = next
        end

        if res.consume then
            break
        end
    end

    return nil
end

function Motion:reset()
    error("please implement me daddy")
    vim.schedule(function()
        print(self)
    end)
end

---@return APMMotionItem
function Motion:create_motion_item()
    local previous_time = self.timings[1]
    local timings = {}

    for i = 2, #self.timings do
        table.insert(timings, math.floor((self.timings[i] - previous_time)))

        previous_time = self.timings[i]
    end

    return {
        chars = self.chars,
        timings = timings,
    }
end

return {
    Motion = Motion,
    get_char = get_char,
}
