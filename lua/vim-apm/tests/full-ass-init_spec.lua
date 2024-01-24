local eq = assert.are.same
local apm = require("vim-apm")
local APMBussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")
local utils = require("vim-apm.tests.utils")

local function close_to(expected, received, margin)
    margin = margin or 5
    return math.abs(expected - received) < margin
end

describe("APM", function()
    before_each(function()
        apm:clear()
    end)
    it("apm - memory-reporter", function()
        apm:setup({
            reporter = {
                type = "memory",
                interval_options = {
                    report_interval = 5000,
                    apm_report_period = 5000,
                }
            },
        });


        --- @type number
        local apm_stats = nil;
        --- @type APMStatsJson
        local stats = nil;

        APMBussin:listen(Events.APM_REPORT, function(a)
            apm_stats = a
        end)

        APMBussin:listen(Events.STATS, function(s)
            stats = s
        end)

        local buffer = vim.fn.bufnr("lua/vim-apm/tests/test-file", true)
        vim.api.nvim_set_current_buf(buffer)
        vim.api.nvim_win_set_cursor(0, {1, 0})
        --vim.api.nvim_feedkeys("23jci{hello worldkdi(itrue", "t", false)
        -- TOOD: teej check out run.lua
        -- vim.api.nvim_feedkeys("23j", "t", false)

        --- this is technically not quite accurate.  there is operator pending
        --- mode that is created with ci{ but we will ignore that
        ---
        --- if tj comes back and i have to do this, i am going to create a
        --- builder because this sucks
        local keys = utils.create_play_keys("23jci{")
        local time_in_normal = #"23jci{" * 100

        table.insert(keys, utils.create_play_key_mode_change({"n", "i"}))
        time_in_normal = time_in_normal + 100

        utils.create_play_keys("hello world", keys)
        local time_in_insert = #"hello world" * 100;

        table.insert(keys, utils.create_play_key_mode_change({"i", "n"}))
        time_in_insert = time_in_insert + 100

        utils.create_play_keys("kdi(i", keys)
        time_in_normal = time_in_normal + #"kdi(i" * 100;

        table.insert(keys, utils.create_play_key_mode_change({"n", "i"}))
        time_in_normal = time_in_normal + 100

        utils.create_play_keys("true", keys)
        time_in_insert = time_in_insert + #"true" * 100;

        table.insert(keys, utils.create_play_key_mode_change({"i", "n"}))
        time_in_insert = time_in_insert + 100

        utils.play_keys(keys, 100)

        local remaining_time_in_normal = 5000 - time_in_normal - time_in_insert

        vim.wait(50000, function()
            return apm_stats ~= nil
        end)

        eq(true, close_to(remaining_time_in_normal + time_in_normal, stats.modes.n, 100))
    end)
end)


