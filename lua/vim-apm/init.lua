local Utils = require("vim-apm.utils")
local Bucket = require("vim-apm.buckets")
local KeyStroker = require("vim-apm.keystroker")

timerIdx = timerIdx or 0
buckets = buckets or Bucket:new(60 * 5, 5)
bufh = bufh or 0
win_id = win_id or 0
active = active or false
keyStrokes = KeyStroker:new()

local INSERT = 1
local NORMAL = 2
local COMMAND = 3
local mode = NORMAL

local function on_insert()
    mode = INSERT
    keyStrokes:onInsert()
end

local function on_normal()
    mode = NORMAL
    keyStrokes:onNormal()
end

local function shutdown()
    if win_id ~= 0 then
        vim.api.nvim_win_close(win_id, true)
    end

    if bufh ~= 0 then
        vim.cmd(string.format("bdelete! %s", bufh))
    end

    buckets = nil
    timerIdx = timerIdx + 1
    bufh = 0
    win_id = 0

    -- get namespace id for "vim-apm" & clear keystroke callback function.
    namespace_id = vim.api.nvim_create_namespace("vim-apm")
    vim.register_keystroke_callback(nil, namespace_id)

    active = false
end

local function on_winclose(closed_id)
    if win_id == tonumber(closed_id) then
        win_id = 0
    end
end

local function on_resize()
    if active == false then
        return
    end

    local w = vim.api.nvim_win_get_width(0)
    local h = vim.api.nvim_win_get_height(0)

    local width = 14
    local row = 1
    local col = w - width
    local config = {style="minimal", relative='win', row=row, col=col, width=width, height=3}

    if bufh == 0 then
        bufh = vim.api.nvim_create_buf(false, true)
    end

    if win_id == 0 then
        win_id = vim.api.nvim_open_win(bufh, false, config)
    else
        vim.api.nvim_win_set_config(win_id, config)
    end
end

-- I don't know how to do this at all.
local function on_command()
    mode = COMMAND
end

local function create_window_and_buf()
end

local function apm()
    keyStrokes:reset()
    active = true
    timerIdx = timerIdx + 1
    local localTimerId = timerIdx

    on_resize()

    if bufh == 0 then
        error("OHH NO, The buffer has been not created!! You are doomed to live a life of mediocrity.")
    end

    -- Create a timer handle (implementation detail: uv_timer_t).
    local timer = vim.loop.new_timer()

    -- 5 minutes worth of apm, in 5 second chunks.
    -- That way I can calculate your APM over time
    local lastSeenKeys = {}
    local idx = 1
    local length = 10

    -- Waits 1000ms, then repeats every 750ms until timer:close().
    timer:start(1000, 750, vim.schedule_wrap(function()

        local currentTime = Utils.getMillis()

        if localTimerId < timerIdx then
            timer:close()
            return
        end

        buckets:getCurrentBucket(NORMAL, currentTime)
        buckets:getCurrentBucket(INSERT, currentTime)

        -- also consider using insert for apm calculations.
        local nStroke, nScore, iStroke, iScore = buckets:calculateAPM()

        vim.api.nvim_buf_set_lines(bufh, 0, 2, false, {
            string.format("n: %s / %s", math.floor(nScore), math.floor(nStroke)),
            string.format("i: %s", math.floor(iScore)),
            string.format("t: %s / %s", math.floor(iScore) + math.floor(nScore), math.floor(iStroke) + math.floor(nStroke)),
        })

        -- Print the goods for the apm
    end))

    vim.register_keystroke_callback(function(buf)
        ok, msg = pcall(function()
            local currentTime = Utils.getMillis()
            keyStrokes:onKey(buf)

            if mode == NORMAL then
                lastSeenKeys[idx] = buf
            end

            _, bucket = buckets:getCurrentBucket(mode, currentTime)

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

        if not ok then
            keyStrokes:reset()
            print("Error: ", msg)
        end
    end, vim.api.nvim_create_namespace("vim-apm"))
end

return {
    apm = apm,
    on_insert = on_insert,
    on_normal = on_normal,
    on_command = on_command,
    on_resize = on_resize,
    shutdown = shutdown,
    on_winclose = on_winclose,
}


