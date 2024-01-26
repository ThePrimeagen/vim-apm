local eq = assert.are.same
local Stats = require("vim-apm.stats")
local utils = require("vim-apm.utils")

local function score(s)
    return math.floor(s * 100)
end

describe("Stats", function()
    local old_now = utils.now
    local now = 0
    local function spoof_now()
        return now
    end

    before_each(function()
        now = 0
        utils.now = spoof_now
    end)

    after_each(function()
        utils.now = old_now
    end)

    it("calculator", function()
        local calc = Stats.Calculator.new(5, 5)

        calc:push({
            chars = "dap",
            timings = { 5, 10 },
        })

        now = 1
        calc:push({
            chars = "dap",
            timings = { 5, 10 },
        })

        eq(1.5, utils.normalize_number(calc.apm_sum))

        now = 2
        calc:push({
            chars = "dap",
            timings = { 5, 10 },
        })

        eq(score(utils.normalize_number(calc.apm_sum)), score(1.5 + 1 / 3))

        now = 6
        calc:push({
            chars = "7j",
            timings = { 5, 10 },
        })

        eq(score(utils.normalize_number(calc.apm_sum)), score(0.5 + 1 / 3 + 1))

        now = 8
        calc:push({
            chars = "4j",
            timings = { 5, 10 },
        })

        eq(score(utils.normalize_number(calc.apm_sum)), score(0.5 + 1))
    end)

    it("calculator -- repeat count test", function()
        local calc = Stats.Calculator.new(5, 5)

        for _ = 1, 5 do
            calc:push({ chars = "dap", timings = { 5, 10 } })
        end

        eq(
            utils.normalize_number(0.16666666),
            calc:push({ chars = "dap", timings = { 5, 10 } })
        )
        eq(1, calc:push({ chars = "j", timings = { 5, 10 } }))
        eq(0.5, calc:push({ chars = "7j", timings = { 5, 10 } }))

        -- there are 3 daps left in the previous
        eq(0.25, calc:push({ chars = "7d4ap", timings = { 5, 10 } }))
    end)

    it("stats merge", function()
        local stats = Stats.Stats.new()
        stats.modes = {
            n = 69,
            v = 420,
            i = 1337,
        }

        stats.motions = {
            dap = { count = 1, timings_total = 3 },
            ["<n>dap"] = { count = 2, timings_total = 4 },
        }

        stats.write_count = 10
        stats.buf_enter_count = 20
        stats._time_to_insert = 30
        stats._time_to_insert_count = 40
        stats._time_in_insert = 50
        stats._time_in_insert_count = 60

        local json = {
            motions = {
                dap = { count = 5, timings_total = 7 },
                j = { count = 6, timings_total = 8 },
            },
            modes = {
                c = 42,
                v = 1,
                i = 2,
            },
            write_count = 1,
            buf_enter_count = 2,
            time_to_insert = 3,
            time_to_insert_count = 4,
            time_in_insert = 5,
            time_in_insert_count = 6,
        }

        local new_json = stats:merge(json)
        eq({
            motions = {
                dap = { count = 6, timings_total = 10 },
                ["<n>dap"] = { count = 2, timings_total = 4 },
                j = { count = 6, timings_total = 8 },
            },
            modes = {
                c = 42,
                n = 69,
                v = 421,
                i = 1339,
            },
            write_count = 11,
            buf_enter_count = 22,
            time_to_insert = 33,
            time_to_insert_count = 44,
            time_in_insert = 55,
            time_in_insert_count = 66,
        }, new_json)
    end)

    it("stats motion", function()
        local stats = Stats.Stats.new()
        stats:motion({
            chars = "dap",
            timings = { 5, 10 },
        })

        eq({
            dap = { count = 1, timings_total = 15 },
        }, stats.motions)

        stats:motion({
            chars = "dap",
            timings = { 5, 10 },
        })

        eq({
            dap = { count = 2, timings_total = 30 },
        }, stats.motions)
    end)
end)
