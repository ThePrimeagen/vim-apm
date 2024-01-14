local eq = assert.are.same
local Stats = require("vim-apm.reporter.stats")
local utils = require("vim-apm.utils")

function score(s)
    return math.floor(s * 100)
end

describe("Stats", function()
    local old_now = utils.now
    local now = 0
    function spoof_now()
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
        local calc = Stats.APMCalculator.new(5, 5)

        calc:push({
            chars = "dap",
            timings = {5, 10},
        })

        now = 1
        calc:push({
            chars = "dap",
            timings = {5, 10},
        })

        eq(score(calc.apm_sum), score(1.5))

        now = 2
        calc:push({
            chars = "dap",
            timings = {5, 10},
        })

        eq(score(calc.apm_sum), score(1.5 + 1/3))

        now = 6
        calc:push({
            chars = "7j",
            timings = {5, 10},
        })

        eq(score(calc.apm_sum), score(.5 + 1/3 + 1))

        now = 8
        calc:push({
            chars = "4j",
            timings = {5, 10},
        })

        eq(score(calc.apm_sum), score(.5 + 1))
    end)
end)

