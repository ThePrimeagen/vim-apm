local eq = assert.are.same
local apm = require("vim-apm")
local APMBussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")
local FauxKey = require("vim-apm.tests.faux-key")
local utils = require("vim-apm.utils")

local function key_sequence_1()
    return FauxKey.new()
        :add_keys("jjjkkki")
        :to_mode({ "n", "i" })
        :add_keys("hollo werld")
        :to_mode({ "i", "n" })
        :play()
end

---@param stats APMStatsJson
local function expect_sequence_1(stats)
    eq({
        i = { count = 1 },
        k = { count = 3 },
        j = { count = 3 },
    }, stats.motions)
end

local function key_sequence_2()
    -- dd, j, d<n>j, d<n>k, d<n>d
    return FauxKey.new():add_keys("ddjd3jd7kd3d"):play()
end

local function expect_sequence_2(stats)
    eq({
        i = { count = 1 },
        k = { count = 3 },
        j = { count = 4 },
        dd = { count = 1 },
        ["d<n>j"] = { count = 1 },
        ["d<n>k"] = { count = 1 },
        ["d<n>d"] = { count = 1 },
    }, stats.motions)
end

-- played after you redo the sequence from file contents
local function expect_sequence_3(stats)
    eq({
        i = { count = 2 },
        k = { count = 6 },
        j = { count = 7 },
        dd = { count = 1 },
        ["d<n>j"] = { count = 1 },
        ["d<n>k"] = { count = 1 },
        ["d<n>d"] = { count = 1 },
    }, stats.motions)
end

describe("APM", function()
    --- @type APMStatsJson
    local stats = nil
    local count = 0
    local interval = 500

    local function wait(c)
        vim.wait(interval + 100, function()
            return count == c
        end, 10)
    end

    local function link_listeners()
        -- how to suppress?
        stats = nil

        count = 0

        --@param s APMStatsJson
        APMBussin:listen(Events.STATS, function(s)
            count = count + 1
            stats = s
        end)
    end

    before_each(function()
        pcall(vim.loop.fs_unlink, "/tmp/vim-apm.json")
        apm:clear()

        local buffer = vim.fn.bufnr("lua/vim-apm/tests/test-file", true)
        vim.api.nvim_set_current_buf(buffer)
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end)

    after_each(function()
        pcall(vim.loop.fs_unlink, "/tmp/vim-apm.json")
        apm:clear()
    end)

    it("apm - memory-reporter", function()
        apm:setup({
            reporter = {
                type = "memory",
                interval_options = {
                    report_interval = interval,
                },
            },
        })

        link_listeners()

        key_sequence_1()
        wait(1)
        eq(1, count)
        expect_sequence_1(stats)

        key_sequence_2()
        wait(2)
        eq(2, count)
        expect_sequence_2(stats)

    end)

    it("apm - file-reporter", function()
        local setup_opts = {
            reporter = {
                type = "file",
                uri = "/tmp/vim-apm.json",
                interval_options = {
                    report_interval = interval,
                    apm_report_period = interval,
                },
            },
        }
        apm:setup(setup_opts)

        link_listeners()

        key_sequence_1()
        wait(1)
        eq(1, count)
        expect_sequence_1(stats)

        key_sequence_2()
        wait(2)
        eq(2, count)
        expect_sequence_2(stats)

        local ok, stats_from_file = utils.read_file("/tmp/vim-apm.json")
        eq(true, ok)
        eq(stats_from_file, stats)

        apm:clear()
        vim.wait(100, function() return false end)
        apm:setup(setup_opts)

        link_listeners()

        key_sequence_1()
        wait(1)
        eq(1, count)
        expect_sequence_3(stats)

    end)

end)
