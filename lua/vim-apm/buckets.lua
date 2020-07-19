local Utils = require("vim-apm.utils")

local function createApmBucket(time)
    local item = {}

    -- We can get way more creative, but for now, lets keep it simple.
    item.score = 0.0
    item.strokes = 0.0
    item.time_stamp = time

    return item
end

local normalBuckets = {}
local insertBuckets = {}
local lastSeenKeys = {}
local idx = 1
local length = 10
local historicalTime = 60 * 1 * 5 -- because lua be like that
local bucketTime = 5 * 1
local bucketCount = historicalTime / bucketTime + 1
local usedBucketCount = 1

local function getCurrentBucket(mode)

end

return {
    getCurrentBucket = getCurrentBucket
}

