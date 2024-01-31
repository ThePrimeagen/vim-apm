if VimAPMRequired then
    require("vim-apm"):clear()
end

R("vim-apm")

local apm = require("vim-apm")
apm:setup({
    reporter = {
        type = "network",
    }
})

--[[
vim.on_key(function(key)
    print("key: " .. key)
end)


vim.api.nvim_feedkeys("23jci{hello worldkdi(itrue", "t", false)

--[[
hello world

he ntoheuoeuaoeunato euoeuaoeuoaeu
aoeuaoeutaoeuaoeuaoeunth
aoeuoaeuoaeuth
aoeuoaeuoaeuaoeuoaeuaoeu

oaentuh
aonetuh
naoteu
ntoaeh
ntaoehntaoeu

aoenuthaonetuhaonteuhnt
ntoehu
ntoaheu
ntaoheuntoah
untaoh
euoaeuoaeu

ntaoheuntoheu } onateuhnotehu

if (true) {
    ntoheuntoheutn
}
--]]
