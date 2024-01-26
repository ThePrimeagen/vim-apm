local eq = assert.are.same
local apm = require("vim-apm")
local APMBussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")
local FauxKey = require("vim-apm.tests.faux-key")
local Stats = require("vim-apm.stats")

local function close_to(expected, received, margin, heading)
    heading = heading or "close_to"
    margin = margin or 5
    eq(
        true,
        math.abs(expected - received) < margin,
        string.format(
            "%s: expected %s to be close to %s",
            heading,
            received,
            expected
        )
    )
end

---@param expected APMAggregateMotionValue
---@param stats_json APMStatsJson
---@param margin number
local function motion_eq(motion_string, expected, stats_json, margin)
    local received = stats_json.motions[motion_string]
    eq(true, received ~= nil)
    eq(
        expected.count,
        received.count,
        string.format(
            "motion: count(%s): %d vs %d",
            motion_string,
            expected.count,
            received.count
        )
    )
    close_to(
        expected.timings_total,
        received.timings_total,
        margin,
        string.format("timings_total(%s)", motion_string)
    )
end

local function key_sequence_1()
    --- this is technically not quite accurate.  there is operator pending
    --- mode that is created with ci{ but we will ignore that
    ---
    --- if tj comes back and i have to do this, i am going to create a
    --- builder because this sucks
    return FauxKey.new()
        :add_keys("23jci{")
        :to_mode({ "n", "i" }, 100)
        :add_keys("hello world", 69)
        :to_mode({ "i", "n" }, 75)
        :add_keys("kdi(i", 50)
        :to_mode({ "n", "i" }, 25)
        :add_keys("true")
        :to_mode({ "i", "n" }, 50)
        :play()
end

local function key_sequence_2()
    return FauxKey.new()
        :add_keys("jjjkkki")
        :to_mode({ "n", "i" })
        :add_keys("hollo werld")
        :to_mode({ "i", "n" })
        :play()
end

local function expect_sequence_1(remaining_time, mode_times, stats)
    close_to(remaining_time + mode_times.n, stats.modes.n, 10)
    close_to(mode_times.i, stats.modes.i, 10)
    motion_eq("<n>j", { count = 1, timings_total = 200 }, stats, 3)
    motion_eq("ci{", { count = 1, timings_total = 200 }, stats, 3)
    motion_eq("k", { count = 1, timings_total = 0 }, stats, 3)
    motion_eq("di(", { count = 1, timings_total = 100 }, stats, 3)
    motion_eq("i", { count = 1, timings_total = 0 }, stats, 3)

    close_to(stats.time_to_insert, 69 + 100, 3)
    eq(stats.time_to_insert_count, 2)

    -- hello world and true
    close_to(mode_times.i, stats.time_in_insert)
    eq(#"hello world" + #"true", stats.time_in_insert_count)
end

local function expect_sequence_2(
    remaining_time,
    mode_times,
    stats,
    previous_n_time,
    previous_i_time
)
    close_to(remaining_time + mode_times.n + previous_n_time, stats.modes.n, 10)
    close_to(mode_times.i + previous_i_time, stats.modes.i, 10)

    -- previous timings
    motion_eq("<n>j", { count = 1, timings_total = 200 }, stats, 5)
    motion_eq("ci{", { count = 1, timings_total = 200 }, stats, 5)
    motion_eq("di(", { count = 1, timings_total = 100 }, stats, 5)

    -- updated timings
    motion_eq("k", { count = 4, timings_total = 0 }, stats, 5)
    motion_eq("i", { count = 2, timings_total = 0 }, stats, 5)

    -- new timings
    motion_eq("j", { count = 3, timings_total = 0 }, stats, 5)

    close_to(stats.time_to_insert, 69 + 100 + 100, 5)
    eq(stats.time_to_insert_count, 3)

    -- hello world and true
    close_to(mode_times.i + previous_i_time, stats.time_in_insert)
    eq(#"hello world" + #"true" + #"hollo werld", stats.time_in_insert_count)
end

describe("APM", function()
    --- @type number
    local apm_stats = nil
    --- @type APMStatsJson
    local stats = nil
    local count = 0

    local function link_listeners()
        -- how to suppress?
        stats = nil
        apm_stats = nil

        count = 0

        APMBussin:listen(Events.APM_REPORT, function(a)
            count = count + 1
            apm_stats = a
        end)

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
                    report_interval = 5000,
                    apm_report_period = 5000,
                },
            },
        })

        link_listeners()

        local _, time_taken, mode_times = key_sequence_1()

        vim.wait(50000, function()
            return count == 2
        end)

        local remaining_time = 5000 - time_taken
        expect_sequence_1(remaining_time, mode_times, stats)

        local previous_n_time = stats.modes.n
        local previous_i_time = stats.modes.i

        _, time_taken, mode_times = key_sequence_2()
        vim.wait(50000, function()
            return count == 4
        end)

        remaining_time = 5000 - time_taken
        expect_sequence_2(
            remaining_time,
            mode_times,
            stats,
            previous_n_time,
            previous_i_time
        )

        local _ = apm_stats
    end)

    it("apm - file-reporter", function()
        apm:setup({
            reporter = {
                type = "file",
                uri = "/tmp/vim-apm.json",
                interval_options = {
                    report_interval = 5000,
                    apm_report_period = 5000,
                },
            },
        })

        link_listeners()

        local _, time_taken, mode_times = key_sequence_1()

        vim.wait(7000, function()
            return count == 2
        end)

        local remaining_time = 5000 - time_taken
        expect_sequence_1(remaining_time, mode_times, stats)

        local previous_n_time = stats.modes.n
        local previous_i_time = stats.modes.i

        _, time_taken, mode_times = key_sequence_2()
        vim.wait(7000, function()
            return count == 4
        end)

        remaining_time = 5000 - time_taken
        expect_sequence_2(
            remaining_time,
            mode_times,
            stats,
            previous_n_time,
            previous_i_time
        )
    end)

    it(
        "apm - file reporter should use its file as the base source of truth upon merging",
        function()
            apm:setup({
                reporter = {
                    type = "file",
                    uri = "/tmp/vim-apm.json",
                    interval_options = {
                        report_interval = 5000,
                        apm_report_period = 5000,
                    },
                },
            })

            link_listeners()
            local empty_stats = Stats.empty_stats_json()
            empty_stats.motions["<n>j"] = { count = 1, timings_total = 200 }

            local file = vim.loop.fs_open("/tmp/vim-apm.json", "w", 493)
            local out_json = vim.fn.json_encode(empty_stats)
            local ok2, _ = pcall(vim.loop.fs_write, file, out_json)
            vim.loop.fs_close(file)
            eq(true, ok2)

            vim.wait(7000, function()
                return count == 2
            end)

            eq(stats.motions, empty_stats.motions)
        end
    )
end)
