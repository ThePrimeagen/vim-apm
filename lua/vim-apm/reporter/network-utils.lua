local M = {}

local ZERO = string.byte("0")

M.VERSION = 0
M.Types = {
    Motion = 0,
    Write = 2,
    BufNavigate = 2,
}

---@param length number
---@return string
function M.to_apm_length(length)
    return string.char(ZERO + length)
end

---@param motion APMMotionItem
---@return string
function M.encode_motion(motion)
    local chars = motion.chars
    local chars_len = M.to_apm_length(#chars)

    local timings = table.concat(motion.timings, ",")
    local total_len = M.to_apm_length(#chars + #timings + 1)

    local version = M.to_apm_length(M.VERSION)
    local type = M.to_apm_length(M.Types.Motion)

    return version .. type .. total_len .. chars_len .. chars .. timings
end

return M
