local M = {}

local search_motion = {
    f = true,
    F = true,
    t = true,
    T = true,
}

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

    if #chars > 1 then
        local matched = chars:sub(#chars, #chars):match("%d")
        local search = search_motion[chars:sub(#chars - 1, #chars - 1)]

        if matched ~= nil and search then
            table.insert(out, chars:sub(#chars, #chars))
        end
    end

    return table.concat(out, "")
end

---@param chars string
---@return string
function M.generate_motion_key(chars)
    local out = {}
    local added_number_key = false
    for i = 1, #chars do
        local char = chars:sub(i, i)
        if char:match("%d") == nil then
            table.insert(out, char)
            added_number_key = false
        elseif not added_number_key then
            table.insert(out, "<n>")
            added_number_key = true
        end
    end
    return table.concat(out)
end

---@param motion string
---@return boolean
function M.is_command(motion)
    local start_idx = 1
    for j = 1, #motion do
        local char = motion:sub(j, j)
        if char:match("%d") == nil then
            start_idx = j
            break
        end
    end

    local command = motion:sub(start_idx, start_idx)
    return command == "d" or command == "c" or command == "y" or command == "v"
end

---@param motion string
---@param motion_parts (string | number)[] | nil
---@return (string | number)[]
function M.parse_motion_parts(motion, motion_parts)
    local start_idx = 1
    for j = 1, #motion do
        local char = motion:sub(j, j)
        if char:match("%d") == nil then
            start_idx = j
            break
        end
    end

    motion_parts = motion_parts or {}
    if start_idx > 1 then
        local disnumbered = motion:sub(1, start_idx - 1)
        table.insert(motion_parts, tonumber(disnumbered))
    else
        table.insert(motion_parts, 1)
    end

    local command = motion:sub(start_idx, start_idx)
    if command == "d" or command == "c" or command == "y" or command == "v" then
        table.insert(motion_parts, command)
        return M.parse_motion_parts(
            motion:sub(start_idx + 1, #motion),
            motion_parts
        )
    end
    table.insert(motion_parts, motion:sub(start_idx, #motion))
    return motion_parts
end

return M
