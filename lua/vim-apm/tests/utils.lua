local float = require("vim-apm.ui.float")

local M = {}

function M.clear_memory()
    if float.buf_id ~= nil then
        float:toggle()
    end

    require("plenary").reload.reload_module("vim-apm")
end

return M
