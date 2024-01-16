
## Vim APM
This is still a very alpha application but should be a good time to use.

### Please file issues for
* anytime you get an error
* absolutely not working
* missing motions or incorrect motions

### Getting Started
Here is my Lazy `config` function.

```lua
local apm = require("vim-apm")

apm:setup({})
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

