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

        local buffer = vim.fn.bufnr("lua/vim-apm/tests/test-file", true)
        vim.api.nvim_set_current_buf(buffer)
        vim.api.nvim_win_set_cursor(0, {1, 0})
        utils.play_keys("23jci{hello worldkdi(itrue", 100)

        vim.wait(50000, function()
            return apm_stats ~= nil
        end)

        eq(apm_stats, {})
        eq(stats, {})
    end)
end)


