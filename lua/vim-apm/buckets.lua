local Utils = require("vim-apm.utils")
-- Lua

-- GLOBALSZ???
local INSERT = 1
local NORMAL = 2
local minBucketDuration = 60

local function calculateAPM(buckets, length, bucketTime)
    local scoreSum = 0
    local strokeSum = 0
    local bucketCount = 0

    for i = 1, length, 1 do
        local b = buckets[i]

        if b ~= nil then
            strokeSum = strokeSum + b.strokes
            scoreSum = scoreSum + b.score
            bucketCount = bucketCount + 1
        end
    end

    local period = bucketTime * bucketCount
    if period < minBucketDuration then
        period = minBucketDuration
    end

    period = period / 60

    -- TODO: Probably should make this more awesome.
    if strokeSum == 0 or scoreSum == 0 or period == 0 then
        return 0, 0
    end

    return strokeSum / period, scoreSum / period
end

local function createApmBucket(time)
    local item = {}

    -- We can get way more creative, but for now, lets keep it simple.
    item.score = 0.0
    item.strokes = 0.0
    item.time_stamp = time

    return item
end

local Bucket = {}
function Bucket:new(totalTime, timePerBucket)
    local newBucket = {
        totalTime = totalTime,
        timePerBucket = timePerBucket,
        usedBucketCount = 0,
        totalBuckets = math.ceil(totalTime / timePerBucket),
        startTime = Utils.getMillis(),
        normalBuckets = {},
        insertBuckets = {},
    }

    self.__index = self
    return setmetatable(newBucket, self)
end

function Bucket:calculateAPM()
    local nStrokes, nScore = calculateAPM(self.normalBuckets, self.usedBucketCount, self.timePerBucket)
    local iStrokes, iScore = calculateAPM(self.insertBuckets, self.usedBucketCount, self.timePerBucket)
    return nStrokes, nScore, iStrokes, iScore
end

function Bucket:getCurrentBucket(mode, timestamp)
    if timestamp == nil then
        timestamp = Utils.getMillis()
    end

    local buckets = self.normalBuckets
    if mode == INSERT then
        buckets = self.insertBuckets
    end

    local timeSinceStart = timestamp - self.startTime
    local bucketIdx = math.floor(
        (timeSinceStart % self.totalTime) / self.timePerBucket) + 1

    if buckets[bucketIdx] == nil or (timestamp - buckets[bucketIdx].time_stamp > self.totalTime) then
        buckets[bucketIdx] = createApmBucket(timestamp)

        if self.usedBucketCount < self.totalBuckets then
            self.usedBucketCount = self.usedBucketCount + 1
        end
    end

    return bucketIdx, buckets[bucketIdx]
end

return Bucket
