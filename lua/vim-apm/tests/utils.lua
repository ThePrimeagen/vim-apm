local utils = require("vim-apm.utils")
local M = {}

M.created_files = {}

function M.clear_memory()
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

---@class Spoofer
---@field now function
---@field old_now function
---@field time {now: number}
local Spoofer = {}
Spoofer.__index = Spoofer

function Spoofer.new()
    local old_now = utils.now
    local time = {
        now = 0,
    }
    local function spoof_now()
        return time.now
    end

    return setmetatable({
        now = spoof_now,
        time = time,
        old_now = old_now,
    }, Spoofer)
end

function Spoofer:advance(milli)
    self.time.now = self.time.now + milli
end

function Spoofer:reset()
    self.time.now = 0
    utils.now = self.old_now
end

function Spoofer:start()
    self.time.now = 0
    utils.now = self.now
end

M.Spoofer = Spoofer

return M
