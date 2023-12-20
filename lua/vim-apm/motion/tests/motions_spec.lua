local eq = assert.are.same
local motions = require("vim-apm.motion.motions")

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

    it("or motions", function()
        local number = motions.make_number()
        local a = motions.make_key("a")
        local motion = motions.make_or({
            number,
            a
        })

        local res, next = motion("a")
        eq({ done = true, consume = true }, res)
        eq(nil, next)

        res, next = motion("1")
        eq({ done = false, consume = true }, res)
        eq(nil, next)

        res, next = motion("x")
        eq(nil, res)
        eq(nil, next)
    end)
end)
