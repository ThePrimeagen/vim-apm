local APMBussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")
local M = {}

M.created_files = {}

function M.clear_memory()
    -- TODO: Setup a way to clear listeners based on id
    -- TODO: clear floats through apm main interface
    --if float.buf_id ~= nil then
    --    float:toggle()
    --end


    for _, bufnr in ipairs(M.created_files) do
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
    M.created_files = {}

    require("plenary").reload.reload_module("vim-apm")
end

function M.key(k)
    k = vim.api.nvim_replace_termcodes(k, true, false, true)
    vim.api.nvim_feedkeys(k, "m", false)
end


---@param name string
---@param contents string[]
function M.create_file(name, contents, row, col)
    local bufnr = vim.fn.bufnr(name, true)
    vim.api.nvim_set_option_value("bufhidden", "hide", {
        buf = bufnr,
    })
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, contents)
    if row then
        vim.api.nvim_win_set_cursor(0, { row or 1, col or 0 })
    end

    table.insert(M.created_files, bufnr)
    return bufnr
end

---@class APMFauxKeyEvent
---@field type ON_KEY | MODE_CHANGED
---@field value string | [string, string]

---@param keys APMFauxKeyEvent[]
---@param delay_per_stroke number
function M.play_keys(keys, delay_per_stroke)
    for i = 1, #keys do
        local key = keys[i]
        APMBussin:emit(key.type, key.value)
        vim.wait(delay_per_stroke)
    end
end

---@param keys string
---@return APMFauxKeyEvent[]
function M.create_play_keys(keys, out)
    out = out or {}
    for i = 1, #keys do
        local key = keys:sub(i, i)
        table.insert(out, {
            type = Events.ON_KEY,
            value = key,
        })
    end
    return out
end

---@param mode string[]
---@return APMFauxKeyEvent
function M.create_play_key_mode_change(mode)
    return {
        type = Events.MODE_CHANGED,
        value = mode,
    }
end


return M
