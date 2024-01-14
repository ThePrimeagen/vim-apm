local Network = require("vim-apm.reporter.network-reporter");
local File = require("vim-apm.reporter.file-reporter");

---@class APMReporterIntervalOptions
---@field report_interval? number
---@field apm_period? number
---@field apm_report_period? number

---@class APMReporterOptions
---@field type "network" | "file"
---@field uri string
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
        return File.new(opts.uri, opts.interval_options)
    end
    return Network.new(opts.uri, opts.interval_options)
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

