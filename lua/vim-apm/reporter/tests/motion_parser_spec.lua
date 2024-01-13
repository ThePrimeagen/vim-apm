local eq = assert.are.same
local motion_parser = require("vim-apm.reporter.motion_parser")

describe("Motion Parser", function()
    it("disnumber motions", function()
        eq(motion_parser.disnumber_motion("1"), "")
        eq(motion_parser.disnumber_motion("6d9ap"), "dap")
        eq(motion_parser.disnumber_motion("dap69"), "dap")
    end)

    it("motion parts", function()
        eq({6, "d", 9, "ap"}, motion_parser.parse_motion_parts("6d9ap"))
        eq({6, "j"}, motion_parser.parse_motion_parts("6j"))
    end)
end)

