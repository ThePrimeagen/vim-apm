local eq = assert.are.same
local motion = require("vim-apm.motion")

describe("state", function()

    it("key motions", function()
        local key = motion.KeyMotion.new("f")
        eq({
            done = true,
            result = {
                type = "consume",
                context = {"f"},
            }
        }, key:test("f"))
        eq({
            done = true,
            result = {
                type = "consume",
                context = {"f"},
            }
        }, key:test("f"))

        eq(nil, key:test("g"))

        eq({
            done = true,
            result = {
                type = "consume",
                context = {"f"},
            }
        }, key:test("f"))
    end)

    it("number motions", function()
        local number = motion.NumberMotion.new()

        eq({
            done = false,
        }, number:test("1"))

        eq({
            done = false,
        }, number:test("0"))

        eq({
            done = true,
            result = {
                type = "no-consume",
                context = {10},
            }
        }, number:test("x"))

        eq({
            done = true,
            result = {
                type = "no-consume",
            }
        }, number:test("x"))

    end)

    it("OrMotion", function()
        local number = motion.OrMotion.new({
            motion.NumberMotion.new(),
            motion.KeyMotion.new("f"),
        })

        eq({
            done = false,
        }, number:test("1"))

        eq({
            done = false,
        }, number:test("0"))

        eq({
            done = true,
            result = {
                type = "no-consume",
                context = {10},
            }
        }, number:test("x"))

        eq(nil, number:test("x"))

        eq({
            done = true,
            result = {
                type = "consume",
                context = {"f"},
            }
        }, number:test("f"))

    end)

    it("AndMotion", function()
        local number = motion.AndMotion.new({
            motion.NumberMotion.new(),
            motion.KeyMotion.new("f"),
        })

        eq({
            done = false,
        }, number:test("1"))

        eq({
            done = false,
        }, number:test("0"))

        eq(nil, number:test("x"))

        eq(nil, number:test("x"))

        eq({
            done = true,
            result = {
                type = "consume",
                context = {"f"},
            }
        }, number:test("f"))

        eq({
            done = false,
        }, number:test("1"))
        eq({
            done = true,
            result = {
                type = "consume",
                context = {1, "f"},
            }
        }, number:test("f"))
    end)

    it("nested And and Ors", function()
        -- double letter terminal motions
        -- TODO: Missing gUiw
        local m = motion.AndMotion.new({
            motion.KeyMotion.new("g"),
            motion.OrMotion.new({
                motion.KeyMotion.new("g"),
                motion.KeyMotion.new("q"),
            }),
        });

        eq({
            done = false,
        }, m:test("g"))

        eq({
            done = true,
            result = {
                type = "consume",
                context = {"g", "g"},
            }
        }, m:test("g"))
    end)

end)
