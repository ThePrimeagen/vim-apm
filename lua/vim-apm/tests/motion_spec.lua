local utils = require("vim-apm.tests.utils")
local eq = assert.are.same
local Motion = require("vim-apm.motion")

local key = utils.key;

describe("state", function()
    it("verify fixed_motions", function()
        local motion = Motion.new()

        local fixed_motions = {
            "x",
            "X",
            "s",
            "S",
        }

        for _, v in ipairs(fixed_motions) do
            eq({
                type = "fixed-motion",
                context = v,
            }, motion:feedkey(v))
        end

        eq(nil, motion:feedkey("m"))

    end)

    it("complex motions", function()
        local motion = Motion.new()

        local keys = {
            {{"gg"}},
            {"9", {9, "gg"}},
            {"6", "9", {69, "gg"}},
        }

        for _, v in ipairs(keys) do
            for _, k in ipairs(v) do
                if type(k) == "table" then
                    break
                end
                motion:feedkey(k)
            end

            local expected = v[#v]

            motion:feedkey("g")
            local results = motion:feedkey("g")

            eq({
                type = "complex",
                context = expected,
            }, results)

        end

    end)

end)

