
local M = {}

local ZERO = string.byte(0)

M.VERSION = 0
M.Types = {
    Motion = 0
}

---@param length number
---@return string
function M.to_apm_length(length)
    return string.char(ZERO + length)
end

---@param chars string
---@return string
function M.encode_motion(chars)
    local len = M.to_apm_length(#chars)
    local version = M.to_apm_length(M.VERSION)
    local type = M.to_apm_length(M.Types.Motion)

    return version .. type .. len .. chars
end

return M

