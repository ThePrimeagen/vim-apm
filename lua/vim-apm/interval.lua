local M = {}

local enabled = false
function M.interval(cb, time)
    local function run()
        vim.defer_fn(function()
            if not enabled then
                return
            end
            cb()
            run()
        end, time)
    end
    run()
end

function M.enable()
    enabled = true
end

function M.clear()
    enabled = false
end

return M
