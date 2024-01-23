local eq = assert.are.same
local apm = require("vim-apm")
local APMBussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")


describe("APM", function()
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
        vim.api.nvim_feedkeys("23jci{hello worldkdi(itrue", "m", false)

        vim.wait(5000)
        eq(apm_stats, {})
        eq(stats, {})
    end)
end)

