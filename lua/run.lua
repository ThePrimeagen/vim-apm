-- luacheck: push ignore
if VimAPMRequired then
    require("vim-apm"):clear()
end

R("vim-apm")

local apm = require("vim-apm")
apm:setup({
    reporter = {
        type = "network",
        port = 4000,
        uri = "127.0.0.1",
        network_mode = "immediate",
        token = "69d28f8a-9b5a-4acc-abd9-2bfde9b72ba3",
        interval_options = {
            report_interval = 60000,
        },
    },
})
