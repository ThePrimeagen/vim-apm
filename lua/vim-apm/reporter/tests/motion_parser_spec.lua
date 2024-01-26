local eq = assert.are.same
local motion_parser = require("vim-apm.reporter.motion_parser")

describe("Motion Parser", function()
    it("disnumber motions", function()
        eq(motion_parser.disnumber_motion("1"), "")
        eq(motion_parser.disnumber_motion("6d9ap"), "dap")
        eq(motion_parser.disnumber_motion("dap69"), "dap")

        eq(motion_parser.disnumber_motion("3d9f9"), "df9")
        eq(motion_parser.disnumber_motion("3d9F9"), "dF9")
        eq(motion_parser.disnumber_motion("3d9t9"), "dt9")
        eq(motion_parser.disnumber_motion("3d9T9"), "dT9")
    end)

    it("motion_key generator", function()
        eq("<n>", motion_parser.generate_motion_key("1"))
        eq("<n>d<n>ap", motion_parser.generate_motion_key("6d9ap"))
        eq("dap<n>", motion_parser.generate_motion_key("dap69"))
    end)

    it("motion parts", function()
        eq({ 6, "d", 9, "ap" }, motion_parser.parse_motion_parts("6d9ap"))
        eq({ 6, "j" }, motion_parser.parse_motion_parts("6j"))
    end)

    it("motion parts", function()
        eq(true, motion_parser.is_command("6d9ap"))
        eq(true, motion_parser.is_command("6969d9ap"))
        eq(false, motion_parser.is_command("6j"))
        eq(false, motion_parser.is_command("k"))
    end)
end)
