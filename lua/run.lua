require("vim-apm"):clear()

R("vim-apm")

local apm = require("vim-apm")
apm:setup()
apm:toggle_monitor()

