local eq = assert.are.same
local Stats = require("vim-apm.stats")
local test_utils = require("vim-apm.tests.utils")

describe("Stats", function()
    local spoofer = test_utils.Spoofer.new()

    before_each(function()
        spoofer:start()
    end)

    after_each(function()
        spoofer:reset()
    end)

    it("stats merge", function()
        local stats = Stats.Stats.new()
        stats.modes = {
            n = 69,
            v = 420,
            i = 1337,
        }

        stats.motions = {
            dap = { count = 1 },
            ["<n>dap"] = { count = 2 },
        }

        stats.write_count = 10
        stats.buf_enter_count = 20

        local json = {
            motions = {
                dap = { count = 5 },
                j = { count = 6 },
            },
            modes = {
                c = 42,
                v = 1,
                i = 2,
            },
            write_count = 1,
            buf_enter_count = 2,
        }

        local new_json = stats:merge(json)
        eq({
            motions = {
                dap = { count = 6 },
                ["<n>dap"] = { count = 2 },
                j = { count = 6 },
            },
            modes = {
                c = 42,
                n = 69,
                v = 421,
                i = 1339,
            },
            write_count = 11,
            buf_enter_count = 22,
        }, new_json)
    end)

    it("stats motion", function()
        local stats = Stats.Stats.new()
        stats:motion({
            chars = "dap",
            timings = { 5, 10 },
        })

        eq({
            dap = { count = 1 },
        }, stats.motions)

        stats:motion({
            chars = "dap",
            timings = { 5, 10 },
        })

        eq({
            dap = { count = 2 },
        }, stats.motions)
    end)

    it("stats mode", function()
        local stats = Stats.Stats.new()
        spoofer:advance(10)
        stats:mode("i")
        spoofer:advance(20)
        stats:mode("v")
        spoofer:advance(30)
        stats:mode("n")

        eq({
            n = 10,
            i = 20,
            v = 30,
        }, stats:to_json().modes)
    end)
end)
