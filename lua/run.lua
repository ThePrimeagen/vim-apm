if VimAPMRequired then
    require("vim-apm"):clear()
end

R("vim-apm")

local apm = require("vim-apm")
apm:setup({})
apm:toggle_monitor()

