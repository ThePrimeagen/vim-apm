local M = {}

---@param chars string
---@return string
function M.disnumber_motion(chars)
    local out = {}
    for i = 1, #chars do
        local char = chars:sub(i, i)
        if char:match("%d") == nil then
            table.insert(out, char)
        end
    end
    return table.concat(out)
end

return M
