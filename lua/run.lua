-- luacheck: push ignore
if VimAPMRequired then
    require("vim-apm"):clear()
end

R("vim-apm")
-- luacheck: pop

local apm = require("vim-apm")
apm:setup({
    reporter = {
        type = "network",
    }
})
