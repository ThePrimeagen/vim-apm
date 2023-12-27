local eq = assert.are.same
local motions = require("vim-apm.motion.motions")
local State = motions.State

describe("state", function()
    it("key motions", function()
        local key = motions.make_key("a")
        local res, next = key("a")

        eq({ done = true, consume = true }, res)
        eq(nil, next)

        res, next = key("x")

        eq(nil, res)
        eq(nil, next)
    end)

    it("number motions", function()
        local number = motions.make_number()
        local res, next = number("a")

        eq({ done = true, consume = false }, res)
        eq(nil, next)

        res, next = number("1")

        eq({ done = false, consume = true }, res)
        eq(nil, next)
    end)

    it("or motions with number combo", function()
        local j = motions.make_key("j")
        local number = motions.make_number(j)
        local motion = motions.make_or(number)

        local res, next = motion("1")
        eq({ done = false, consume = true }, res)
        eq(nil, next)

        res, next = motion("j")

        eq(State.DONE_NO_CONSUME, res)

        res, next = next("j")
        eq(State.DONE_CONSUME, res)
        eq(nil, next)
    end)
end)
