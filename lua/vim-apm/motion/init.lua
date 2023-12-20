---@class VimMotion
---@field head MotionFunction
---@field curr MotionFunction | nil
---@field chars string
local Motion = {}
Motion.__index = Motion

function Motion.new(head)
    return setmetatable({
        head = head,
        curr = nil,
        chars = "",
    }, Motion)
end

---@param key string
---@return string | nil
function Motion:feedkey(key)

    if self.curr == nil then
        self.curr = self.head
        self.chars = ""
    end

    while true do
        if self.curr == nil then
            error("infalible: curr is nil")
        end

        local res, next = self.curr(key)

        if res == nil then
            self.curr = nil
            return nil
        end

        if res.consume then
            self.chars = self.chars .. key
        end

        if res.done and next == nil then
            self.curr = nil
            return self.chars
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
    end)
end

return Motion


