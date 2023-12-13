local float = require("vim-api.ui.float")

local M = {}

function M.clear_memory()
    if float.buf_id ~= nil then
        float:toggle()
    end

    require("plenary").reload.reload_module("vim-api")
end

return M
