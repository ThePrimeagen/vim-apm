local eq = assert.are.same
local Motion = require("vim-apm.motion")
local Motions = require("vim-apm.motion.motions")
local MotionTree = require("vim-apm.motion.motion_tree")

local make_key = Motions.make_key
local make_number = Motions.make_number
local make_or = Motions.make_or

local gg = make_key("g", make_key("g"))
local num_gg = make_number(gg)
local num_gg_or_gq = make_number(
    make_key("g",
        make_or(
            make_key("q"),
            make_key("g")
        )
    )
)

describe("state", function()

    local function play(motion, keys)
        for _, v in ipairs(keys) do
            local last_result = nil
            for _, k in ipairs(v) do
                if type(k) == "table" then
                    break
                end
                last_result = motion:feedkey(k)
            end

            eq(v[#v][1], last_result)
        end
    end

    it("gg", function()
        local motion = Motion.new(gg)
        play(motion, {
            {"g", "g", {"gg"}},
        })
    end)

    it("<number>gg", function()
        local motion = Motion.new(num_gg)
        play(motion, {
            {6, 9, "g", "g", {"69gg"}},
        })
    end)

    it("<number>g(g|q)", function()
        local motion = Motion.new(num_gg_or_gq)
        play(motion, {
            {6, 9, "g", "g", {"69gg"}},
        })
        play(motion, {
            {4, 2, 0, "g", "q", {"420gq"}},
        })
    end)

    it("motionless casses", function()
        local motion = Motion.new(num_gg_or_gq)
        play(motion, {
            {4, 2, 0, "g", "x", {nil}},
        })
    end)

    it("all_motions test [positive]", function()
        local motion = Motion.new(MotionTree.all_motions)
        local motions = {
            {"j"},
            {"k"},
            {"6", "9", "j"},
            {"6", "9", "k"},
            {"d", "6", "9", "k"},
            {"c", "6", "9", "j"},
            {"9", "c", "6", "9", "j"},
            {"6", "9", "~"},
            {"v", "i", "w"},
            {"d", "a", "p"},
            {"6", "d", "9", "a", "p"}, -- damn we got that one right....
        }

        for _, list in ipairs(motions) do
            local last_result = nil;
            for _, key in ipairs(list) do
                last_result = motion:feedkey(key)
            end
            eq(table.concat(list, ""), last_result)
        end
    end)

end)

