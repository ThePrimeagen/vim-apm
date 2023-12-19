local eq = assert.are.same
local m = require("vim-apm.motion")

describe("state", function()

    it("key motions", function()
        local motion = m.Motion.new()
        local keys = {
            {"g", "g", {"g", "g"}},
            {"9", "g", "g", {9, "g", "g"}},
            {"6", "9", "G", {69, "G"}},
            {"6", "d", "9", "d", {6, "d", 9, "d"}},
        }

        for _, v in ipairs(keys) do
            local last_result = nil
            for _, k in ipairs(v) do
                if type(k) == "table" then
                    break
                end
                last_result = motion:feedkey(k)
            end

            local expected = v[#v]

            eq({
                type = "consume",
                context = expected,
            }, last_result.result)

        end
    end)

end)

