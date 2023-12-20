local env = vim.fn.environ()

local debug_motions = env.APM_DEBUG_MOTIONS == "1"
local debug_all = env.APM_DEBUG == "1"

return {
    debug_motion = debug_motions or debug_all,
    debug_all = debug_all,
}
