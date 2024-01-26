local eq = assert.are.same
local utils = require("vim-apm.utils")

describe("utils", function()
    it("fit_string", function()
        eq("helloworld", utils.fit_string("hello", "world", 9))
        eq("helloworld", utils.fit_string("hello", "world", 10))
        eq("hello world", utils.fit_string("hello", "world", 11))
        eq("hello  world", utils.fit_string("hello", "world", 12))
    end)
end)
