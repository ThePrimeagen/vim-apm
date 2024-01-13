local eq = assert.are.same
local motion_parser = require("vim-apm.calculator.motion_parser")

describe("Motion Parser", function()
    it("disnumber motions", function()
        eq(motion_parser.disnumber_motion("1"), "")
        eq(motion_parser.disnumber_motion("6d9ap"), "dap")
        eq(motion_parser.disnumber_motion("dap69"), "dap")
    end)
end)

