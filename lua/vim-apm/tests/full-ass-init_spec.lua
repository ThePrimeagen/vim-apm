local eq = assert.are.same
local apm = require("vim-apm")
local APMBussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")
local utils = require("vim-apm.tests.utils")

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


        local apm_stats = nil;
        local stats = nil;

        APMBussin:listen(Events.APM_REPORT, function(a)
            apm_stats = a
        end)

        APMBussin:listen(Events.STATS, function(s)
            stats = s
        end)

        APMBussin:listen(Events.ON_KEY, function(key)
            print("key", key)
        end)

        vim.wait(1000)

        local buffer = vim.fn.bufnr("lua/vim-apm/tests/test-file", true)
        vim.api.nvim_set_current_buf(buffer)
        vim.api.nvim_win_set_cursor(0, {1, 0})
        --vim.api.nvim_feedkeys("23jci{hello worldkdi(itrue", "t", false)
        -- TOOD: teej check out run.lua
        vim.api.nvim_feedkeys("23j", "t", false)

        vim.wait(50000, function()
            return apm_stats ~= nil
        end)

        eq(stats, {})
        eq(apm_stats, {})
    end)
end)


