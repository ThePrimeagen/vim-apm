local Motions = require("vim-apm.motion.motions")
local KeyMotion = Motions.KeyMotion
local NumberMotion = Motions.NumberMotion
local AndMotion = Motions.AndMotion
local OrMotion = Motions.OrMotion

---@param letter string
---@return MotionInterface
local function create_command_motion(letter)
    return AndMotion.new({
        KeyMotion.new(letter),
        OrMotion.new({
            -- TODO: i need to do all the movement motions here
            -- such as dt<letter>
            AndMotion.new({
                NumberMotion.new(),
                KeyMotion.new(letter),
            }),
            KeyMotion.new(letter),
        })
    });
end

---@param letters string
---@return KeyMotion[]
local function create_key_motions(letters)
    local out = {}
    for i = 1, #letters do
        table.insert(out, KeyMotion.new(letters:sub(i, i)))
    end
    return out
end

local key_motions = OrMotion.new({
    NumberMotion.new(),
    -- single letter terminal motions
    -- double letter terminal motions
    -- command motions
    OrMotion.new({
        -- single letter terminal motions
        OrMotion.new(create_key_motions("xXsSG~U")),

        -- double letter terminal motions
        -- TODO: Missing gUiw
        AndMotion.new({
            KeyMotion.new("g"),
            OrMotion.new(create_key_motions("gq")),
        }),

        -- command motions
    }),
})

---@class VimMotion
---@field motions KeyMotion
local Motion = {}

Motion.__index = Motion

function Motion.new()
    return setmetatable({
        motions = key_motions,
    }, Motion)
end

---@param key string
---@return MotionResult | nil
function Motion:feedkey(key)
    return self.motions:test(key)
end

function Motion:reset()
    error("please implement me daddy")
    vim.schedule(function()
    end)
end

local M = {
    Motion = Motion,
    KeyMotion = KeyMotion,
    NumberMotion = NumberMotion,
    AndMotion = AndMotion,
    OrMotion = OrMotion,
}

return M


