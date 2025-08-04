-- luacheck: push ignore
VimAPMRequired = true
-- luacheck: pop

local APM = require("vim-apm.apm")
local float = require("vim-apm.ui.float")
local Reporter = require("vim-apm.reporter")
local Actions = require("vim-apm.actions")
local APMBussin = require("vim-apm.bus")
local Interval = require("vim-apm.interval")

---@class APMOptions
---@field reporter? APMReporterOptions
---@field token_path? string
---@field token? string

---@class Event
---@field buf number
---@field match string

---@class VimApm
---@field apm APM | nil
---@field monitor APMFloat | nil
---@field actions APMActions
---@field reporter APMReporter | nil
local VimApm = {}

VimApm.__index = VimApm

---@return VimApm
function VimApm.new()
    local self = setmetatable({
        enabled = false,
        actions = Actions.new(),
        monitor = float.new(),
        apm = APM.new(),
    }, VimApm)

    return self
end

---@param opts APMOptions
function VimApm:setup(opts)
    ---@type APMOptions
    opts = vim.tbl_extend("force", {}, {
        reporter = Reporter.default_options(),
    }, opts)

    if opts.token_path ~= nil then
        local ok, lines = pcall(vim.fn.readfile, opts.token_path)
        if ok then
            opts.token = lines[1]
        else
            error(
                "vim-apm: failed to read token from file: " .. opts.token_path
            )
        end
    end

    if opts.token ~= nil then
        opts.reporter.token = opts.token
    end

    self:clear()
    self.enabled = true
    Interval.enable()

    self.reporter = Reporter.create_reporter(opts.reporter)

    self.reporter:enable()
    self.actions:enable()
    self.monitor:enable()
    self.apm:enable()
end

function VimApm:clear()
    APMBussin:clear()
    Interval.clear()
    self.actions:clear()
    self.enabled = false

    if self.reporter ~= nil then
        self.reporter:clear()
        self.reporter = nil
    end
end

function VimApm:toggle_monitor()
    self.monitor:toggle()
end

return VimApm.new()
