
## Vim APM
This fork fixes two bugs that made the plugin look broken.

This is still a very alpha application but should be a good time to use.

### Please file issues for
* anytime you get an error
* absolutely not working
* missing motions or incorrect motions

### Getting Started
Here is my Lazy `config` function.

```lua
local apm = require("vim-apm")

-- default opts
local data_path = vim.fn.stdpath("data")
local default_data_path = string.format("%s/vim-apm.json", data_path)
apm:setup({
    reporter = {
        type = "file", -- or "memory", "network" reporter seems to be unfinished
        uri = default_data_path,
        report_interval = 1 * 60 * 1000, -- unused by file reporter
        apm_repeat_count = 10, -- window size for diminishing returns, i.e. lower -> less diminishing returns on repeated motions
        apm_period = 60 * 1000, -- in ms, actions per 1 minute, e.g. use 5*60*1000 for actions per 5 minute period
        apm_report_period = 5 * 1000, -- in ms, updates the apm and stats with a period of this amount
    }
})
vim.keymap.set("n", "<leader>apm", function() apm:toggle_monitor() end)
```

If you don't know how to install plugins, this is probably not for you in this
moment

## Why Go?
* [i did a poll](https://twitter.com/ThePrimeagen/status/1745166587781349888)
* I want to use go templates and htmx and live that simple life style
* I want to use charm cli
* I like go more than typescript
* I like go more than javascript
* I like go more than elixir (ok i haven't tried elixir)
* I don't ackshually know how to program rust

