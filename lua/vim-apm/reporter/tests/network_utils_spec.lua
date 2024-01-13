local eq = assert.are.same
local network_utils = require("vim-apm.reporter.network-utils")

describe("state", function()
    it("should encode a motion packet", function()
        local motion = "69j"
        local packet = network_utils.encode_motion(motion)

        eq("00369j", packet)
    end)
end)

