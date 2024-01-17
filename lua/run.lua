local utils = require("vim-apm.utils")

--if VimAPMRequired then
--    require("vim-apm"):clear()
--end
--
--R("vim-apm")
--
--local apm = require("vim-apm")
--apm:setup({})
--apm:toggle_monitor()
--
--[[
local function read_json_from_file(path)
    local fh = vim.loop.fs_open(path, "r")
    while true do
        local n, bytes = vim.loop.fs_read(fh, 1024)
        print("n", n, "bytes", bytes)
        break
    end
    return vim.fn.json_decode("")
end
--]]
--


    vim.api.nvim_create_autocmd("ModeChanged", {
        group = utils.vim_apm_group_id(),
        callback = function(a, b)
            print(vim.inspect(a), vim.inspect(b))
        end
    })
