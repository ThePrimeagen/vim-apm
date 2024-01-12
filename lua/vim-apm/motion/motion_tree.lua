local Motions = require("vim-apm.motion.motions")

local j = Motions.make_key("j")
local k = Motions.make_key("k")
local x = Motions.make_key("x")
local X = Motions.make_key("X")
local w = Motions.make_key("w")
local b = Motions.make_key("b")
local W = Motions.make_key("W")
local B = Motions.make_key("B")
local tilde = Motions.make_key("~")
local underscore = Motions.make_key("_")
local e = Motions.make_key("e")
local E = Motions.make_key("E")

local simple_motions = Motions.make_or(
    j, k,
    x, X,
    w, b,
    W, B,
    tilde,
    underscore,
    e, E
)

local p = Motions.make_key("p")
local bracket = Motions.make_key("[")
local paren = Motions.make_key("(")
local squirly = Motions.make_key("{")
local c_bracket = Motions.make_key("]")
local c_paren = Motions.make_key(")")
local c_squirly = Motions.make_key("}")

local complex_motion_set = Motions.make_or(
    p,
    b,
    bracket,
    paren,
    squirly,
    c_bracket,
    c_paren,
    c_squirly,
    w,
    W
)

local in_motion = Motions.make_key("i", complex_motion_set)
local around = Motions.make_key("a", complex_motion_set)

local complex_motion = Motions.make_or(
    in_motion,
    around
)

-- yes!
local numbered = Motions.make_number(
    Motions.make_or(
        simple_motions,
        complex_motion
    )
)

local function make_numbered_command_motion(key)
    return Motions.make_number(
        Motions.make_or(
            simple_motions,
            complex_motion,
            Motions.make_key(key)
        )
    )
end

local delete = Motions.make_key("d", make_numbered_command_motion("d"))
local yank = Motions.make_key("y", make_numbered_command_motion("y"))
local cut = Motions.make_key("c", make_numbered_command_motion("c"))
local visual = Motions.make_key("v", numbered)

local command_motions = Motions.make_or(
    yank, delete, cut, numbered
)
local numbered_command_motions = Motions.make_number(
    command_motions
)

-- Ok i think i have built the entire tree
local all_motions = Motions.make_or(
    -- visual motions must start with a v, there is no motion that starts with a number then a visual command
    visual,
    numbered_command_motions
)

return {
    j = j,
    k = k,
    simple_motions = simple_motions,
    numbered_simple_motions = numbered,
    delete = delete,
    cut = cut,
    all_motions = all_motions,
}

