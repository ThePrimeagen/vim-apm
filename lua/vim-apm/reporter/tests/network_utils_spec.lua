local eq = assert.are.same
local network_utils = require("vim-apm.reporter.network-utils")

describe("state", function()
    it("should encode a motion packet", function()
        local motion = {
            chars = "69j",
            timings = { 69, 420 },
        }
        local packet = network_utils.encode_motion(motion)

        eq("00:369j69,420", packet)
    end)
end)
