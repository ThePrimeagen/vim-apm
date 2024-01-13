local APMBussin = require("vim-apm.bus")
local APM = require("vim-apm.apm")
local Actions = require("vim-apm.actions")

---@class APMFileReporter : APMReporter
---@field path string
---@field enabled boolean
---@field _motions APMMotionItem[]
---@field _insert_times number[]
---@field _write_count number
---@field _buf_enter_count number
---@field _write_interval number
local FileReporter = {}
FileReporter.__index = FileReporter

---@param path string
---@param write_interval number | nil
---@return APMFileReporter
function FileReporter.new(path, write_interval)
    return setmetatable({
        path = path,
        enabled = false,
        _motions = {},
        _insert_times = {},
        _write_count = 0,
        _buf_enter_count = 0,
        _write_interval = write_interval or 1000 * 60 * 5,
    }, FileReporter)
end

function FileReporter:enable()
    self.enabled = true

    local function write()
        vim.defer_fn(function()
            write()
        end, self._write_interval)
    end
    write()

    ---@param motion APMMotionItem
    APMBussin:listen(APM.Events.MotionItem, function(motion)
        self._motions[#self._motions + 1] = motion
    end)

    APMBussin:listen(APM.Events.InsertTime, function(insert_time)
        self._insert_times[#self._insert_times + 1] = insert_time
    end)
    APMBussin:listen(Actions.WRITE, function()
        self._write_count = self._write_count + 1
    end)
    APMBussin:listen(Actions.BUF_ENTER, function()
        self._buf_enter_count = self._buf_enter_count + 1
    end)
end

function FileReporter:clear()
end
