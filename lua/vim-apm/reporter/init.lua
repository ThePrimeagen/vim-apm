local Network = require("vim-apm.reporter.network-reporter")
local File = require("vim-apm.reporter.file-reporter")
local Memory = require("vim-apm.reporter.memory-reporter")

---@class APMReporterIntervalOptions
---@field report_interval? number
---@field apm_repeat_count? number
---@field apm_period? number
---@field apm_report_period? number

---@class APMReporterOptions
---@field type "network" | "file" | "memory"
---@field uri? string
---@field port? number only used for network
---@field interval_options? APMReporterIntervalOptions

---@class APMReporter
---@field clear fun(self: APMReporter): nil
---@field enable fun(self: APMReporter): nil

--- TODO: F yo windows
local data_path = vim.fn.stdpath("data")
local default_data_path = string.format("%s/vim-apm.json", data_path)

local function default_options()
    return {
        type = "file",
        uri = default_data_path,
    }
end

---@param opts APMReporterOptions
---@return APMReporter
local function create_reporter(opts)
    if opts.type == "file" then
        if opts.uri == nil then
            opts.uri = default_data_path
        end
        return File.new(opts.uri, opts.interval_options)
    end

    if opts.type == "memory" then
        return Memory.new(opts.uri, opts.interval_options)
    end

    if opts.type == "network" then
        return Network.new(opts)
    end

    error("Unknown reporter type: " .. opts.type)
end

return {
    default_options = default_options,
    file_options = function(path, interval)
        return {
            type = "file",
            interval = interval,
            uri = path,
        }
    end,
    network_options = function(uri, interval)
        return {
            type = "network",
            interval = interval,
            uri = uri,
        }
    end,
    create_reporter = create_reporter,
}
