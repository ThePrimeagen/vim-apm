---@class APMEventNames
---@field MODE_CHANGED "mode"
---@field ON_KEY "on_key"

---@alias ON_KEY "on_key"
---@alias MODE_CHANGED "mode"

return {

    MODE_CHANGED = "mode",
    ON_KEY = "on_key",
    RESIZE = "resize",
    WRITE = "write",
    BUF_ENTER = "buf_enter",

    IDLE_WORK = "idle_work",
    BUSY_WORK = "busy_work",

    STATE_NORMALIZE = "state_normalize",
    STATE_EDITING = "state_editing",
    STATE_IDLE = "state_idle",

    APM_REPORT = "apm",
    MOTION = "motion",
    STATS = "stats-update",
    INSERT_REPORT = "insert_report",
}
