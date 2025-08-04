local utils = require("vim-apm.utils")
local M = {}

local id = 0
local enabled = false
local intervals = {}

local function check()
    local now = utils.now()
    for i = #intervals, 1, -1 do
        local interval = intervals[i]
        if interval.next_time <= now then
            interval.cb()
            interval.next_time = now + interval.time
            vim.defer_fn(check, interval.time)
        end
    end
end

function M.interval(cb, time, name)
    assert(enabled, "intervals must be enabled before they are created")

    id = id + 1
    local _id = id
    local next_time = utils.now() + time
    table.insert(intervals, {
        id = _id,
        name = name,
        cb = cb,
        time = time,
        next_time = next_time
    })

    vim.defer_fn(check, time)
end

---@param resolution number
function M.enable(resolution)
    resolution = resolution or 10
    enabled = true
    intervals = {}
end

function M.clear()
    enabled = false
end

return M
