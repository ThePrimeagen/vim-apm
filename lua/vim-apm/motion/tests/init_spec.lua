local eq = assert.are.same
local MotionModule = require("vim-apm.motion")
local Motion = MotionModule.Motion
local get_char = MotionModule.get_char
local MotionTree = require("vim-apm.motion.motion_tree")

describe("state", function()
    it("all_motions test [positive]", function()
        local motion = Motion.new(MotionTree.all_motions)
        local motions = {
            { "j" },
            { "k" },
            { "6", "9", "j" },
            { "6", "9", "k" },
            { "d", "6", "9", "k" },
            { "c", "6", "9", "j" },
            { "9", "c", "6", "9", "j" },
            { "6", "9", "~" },
            { "v", "i", "w" },
            { "d", "a", "p" },
            { "d", "d" },
            { "6", "d", "9", "d" },
            { "y", "y" },
            { "6", "y", "9", "y" },
            { "c", "c" },
            { "6", "c", "9", "c" },
            { "y", "y" },
            { "6", "y", "9", "y" },
            { "6", "d", "9", "a", "p" }, -- damn we got that one right....
            { "6", "d", "9", "f", "9" }, -- did we? WE DID!! holy
            { "6", "" },
            { "6", "" },
        }

        for _, list in ipairs(motions) do
            local last_result = nil
            for _, key in ipairs(list) do
                last_result = motion:feedkey(key)
            end
            eq(table.concat(list, ""), get_char(last_result))
        end
    end)

    it("all_motions test [negative]", function()
        local motion = Motion.new(MotionTree.all_motions)
        local motions = {
            { "d", "y" },
            { "y", "d" },
            { "c", "d" },
        }

        for _, list in ipairs(motions) do
            local last_result = nil
            for _, key in ipairs(list) do
                last_result = motion:feedkey(key)
            end
            eq(nil, last_result)
        end
    end)
end)
