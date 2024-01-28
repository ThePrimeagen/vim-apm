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

return M
