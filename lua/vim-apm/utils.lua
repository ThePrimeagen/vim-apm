local M = {}

M.vim_apm_group_id = vim.api.nvim_create_augroup("VimApm", {})

function M.on_close(buf_id, cb)
    vim.api.nvim_create_autocmd('BufUnload', {
        group = M.vim_apm_group_id,
        buffer = buf_id,
        callback = function()
            cb()
        end
    })
end

return M
