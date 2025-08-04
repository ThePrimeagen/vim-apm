local eq = assert.are.same
local MotionTree = require("vim-apm.motion.motion_tree")
local Motions = require("vim-apm.motion.motions")

describe("state", function()
    it("simple motions", function()
        eq(MotionTree.j("j"), Motions.State.DONE_CONSUME)
        eq(MotionTree.k("k"), Motions.State.DONE_CONSUME)

        eq(MotionTree.j("k"), nil)
        eq(MotionTree.k("j"), nil)

        eq(MotionTree.simple_motions("j"), Motions.State.DONE_CONSUME)
        eq(MotionTree.simple_motions("k"), Motions.State.DONE_CONSUME)

        local done, next = MotionTree.numbered_simple_motions("9")
        eq(done, Motions.State.NO_DONE_CONSUME)
        eq(next, nil)

        done, next = MotionTree.numbered_simple_motions("k")
        eq(done, Motions.State.DONE_NO_CONSUME)
        eq(next("k"), Motions.State.DONE_CONSUME)

        done, next = MotionTree.all_motions("d")
        eq(done, Motions.State.DONE_NO_CONSUME)

        done, next = next("d")
        eq(done, Motions.State.DONE_CONSUME)

        eq(next("9"), Motions.State.NO_DONE_CONSUME)
        eq(next("9"), Motions.State.NO_DONE_CONSUME)
        eq(next("9"), Motions.State.NO_DONE_CONSUME)

        done, next = next("j")
        eq(done, Motions.State.DONE_NO_CONSUME)

        done, next = next("j")
        eq(Motions.State.DONE_CONSUME, done)
        eq(nil, next)
    end)
end)
