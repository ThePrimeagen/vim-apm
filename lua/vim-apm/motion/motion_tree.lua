local Motions = require("vim-apm.motion.motions")

local j = Motions.make_key("j")
local k = Motions.make_key("k")
local simple_motions = Motions.make_or(j, k)
local numbered_simple_motions = Motions.make_number(simple_motions)

local delete = Motions.make_key("d", numbered_simple_motions)
local cut = Motions.make_key("c", numbered_simple_motions)

local all_motions = Motions.make_or(delete, cut, numbered_simple_motions)

return {
    j = j,
    k = k,
    simple_motions = simple_motions,
    numbered_simple_motions = numbered_simple_motions,
    delete = delete,
    cut = cut,
    all_motions = all_motions,
}
