local Utils = require("vim-apm.utils")

-- written rust two separate moments in my life where I was rock bottom.  But
-- don't worry, I drank a bottle of coconut oil and crushed it.
--
-- Thank you,
--
-- I love,
--
-- Sincerely,
--
-- Yours truly,
--
-- ThePrimeagen
--
-- To prevent multiple timers from showing up when sourcing over and over again.
timerIdx = timerIdx or 0

local function close_window(win_id)
    print("Closing window", win_id)
    vim.fn.nvim_win_close(win_id, true)
end

local function getMillis()
    return os.time()
end

local function createApmBucket(time)
    local item = {}

    -- We can get way more creative, but for now, lets keep it simple.
    item.score = 0.0
    item.strokes = 0.0
    item.time_stamp = time

    return item
end

local INSERT = 1
local NORMAL = 2
local COMMAND = 3
local mode = NORMAL

local function on_insert()
    mode = INSERT
end

local function on_normal()
    mode = NORMAL
end

-- TODO: Stop just hacking, and make something better than this shit pile
local bufh = vim.fn.nvim_create_buf(false, true)
local win_id = 0

local function on_winclose(win_id)
end

local function on_resize()
    print("AM I CALLED?")
    local w = vim.fn.nvim_win_get_width(0)
    local h = vim.fn.nvim_win_get_height(0)

    local width = 14
    local row = 1
    local col = w - width
    local config = {style="minimal", relative='win', row=row, col=col, width=width, height=3}

    if win_id == 0 then
        win_id = vim.api.nvim_open_win(bufh, false, config)
    else
        vim.api.nvim_win_set_config(win_id, config)
    end
end

-- I don't know how to do this at all.
local function on_command()
    print("on_command")
    mode = COMMAND
end

-- All time is in SECONDS because of LUA
local minBucketDuration = 60
local calcCount = 0
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
    calcCount = calcCount + 1

    -- TODO: Probably should make this more awesome.
    if strokeSum == 0 or scoreSum == 0 or period == 0 then
        return 0, 0
    end

    return strokeSum / period, scoreSum / period
end

local startTime = Utils.getMillis()
local historicalTime = 60 * 1 * 5 -- because lua be like that
local bucketTime = 5 * 1
local bucketCount = historicalTime / bucketTime + 1
local usedBucketCount = 1

local function getCurrentBucketIdx(buckets, currentTime)
    local bucket_idx = math.floor(((currentTime - startTime) % historicalTime) / bucketTime) + 1

    -- Bucketidx sucks right now, if you go insert -> normal it will inc it 2x
    -- fix this.
    if buckets[bucket_idx] == nil or (currentTime - buckets[bucket_idx].time_stamp > historicalTime) then

        buckets[bucket_idx] = createApmBucket(currentTime)

        if usedBucketCount < bucketCount then
            usedBucketCount = usedBucketCount + 1
        end
    end

    return bucket_idx, buckets[bucket_idx]
end

local function apm()
    local id = "vim-apm"
    timerIdx = timerIdx + 1
    local localTimerId = timerIdx

    -- listen for all key presses.
    -- Determine if we are in insert mode.
    -- make sure we are async so we don't slow down the input delay
    -- calc some stats
    -- create a floating buffer
    -- render some sweet stats every few seconds
    -- Use variables to either be permament or display for a fixed period of time.

    -- get content
    -- local contents = vim.fn.nvim_buf_get_lines(0, 2, 5, false)

    local lifetime = vim.g.vim_apm_lifetime or 5000

    if bufh == 0 then
        error("OHH NO, The buffer has been not created!! You are doomed to live a life of mediocrity.")
    end

    on_resize()

    -- TODO: When would I ever need to do, this?
    local closed = false

    --[[
    vim.defer_fn(function()
        closed = true
        close_window(win_id)
    end, lifetime)
    ]]

    -- Create a timer handle (implementation detail: uv_timer_t).
    local timer = vim.loop.new_timer()

    -- 5 minutes worth of apm, in 5 second chunks.
    -- That way I can calculate your APM over time
    local normalBuckets = {}
    local insertBuckets = {}
    local lastSeenKeys = {}
    local idx = 1
    local lastTime = getMillis()
    local length = 10

    -- Waits 1000ms, then repeats every 750ms until timer:close().
    timer:start(1000, 750, vim.schedule_wrap(function()

        local currentTime = Utils.getMillis()
        getCurrentBucketIdx(normalBuckets, currentTime)
        getCurrentBucketIdx(insertBuckets, currentTime)

        if localTimerId < timerIdx then
            timer:close()
            return
        end

        -- also consider using insert for apm calculations.
        local nStroke, nScore = calculateAPM(normalBuckets, usedBucketCount, bucketTime)
        local iStroke, iScore = calculateAPM(insertBuckets, usedBucketCount, bucketTime)

        vim.fn.nvim_buf_set_lines(bufh, 0, 2, false, {
            string.format("n: %s / %s", math.floor(nScore), math.floor(nStroke)),
            string.format("i: %s / %s", math.floor(iScore), math.floor(iStroke)),
            string.format("t: %s / %s", math.floor(iScore) + math.floor(nScore), math.floor(iStroke) + math.floor(nScore)),
        })

        -- Print the goods for the apm
    end))

    vim.register_keystroke_callback(id, function(buf)
        local currentTime = getMillis()

        local buckets = normalBuckets
        if mode == INSERT then
            buckets = insertBuckets
        else
            lastSeenKeys[idx] = buf
        end

        bucket_idx, bucket =  getCurrentBucketIdx(buckets, currentTime)

        idx = idx + 1
        if idx == length then
            idx = 1
        end

        local score = 1
        local occurrences = 1

        if mode == NORMAL then
            occurrences = 0
            for i = 1, length, 1 do
                if lastSeenKeys[i] == buf then
                    occurrences = occurrences + 1
                end
            end
        end

        bucket.strokes = bucket.strokes + 1
        bucket.score = bucket.score + 1.0 / occurrences
    end)

    -- autocmd TextChanged * lua require('vim-apm').register_movement()

    --[[

    const width = Math.min(columnSize - 4, Math.max(80, columnSize - 20));:
    const height = Math.min(rowSize - 4, Math.max(40, rowSize - 10));
    const top = (rowSize - height) / 2 - 1;
    const left = (columnSize - width) / 2;
    ]]


    -- set content
    -- vim.fn.nvim_buf_set_lines(0, 24, 24, false, {"Testing"})
end

return {
    apm = apm,
    on_insert = on_insert,
    on_normal = on_normal,
    on_command = on_command,
    on_resize = on_resize,
    on_winclose = on_winclose,
}


