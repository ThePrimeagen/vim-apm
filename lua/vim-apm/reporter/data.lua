local motion_parser = require("vim-apm.reporter.motion_parser")

---@class APMReporterData
---@field motions = {}
---@field commands = {}
---@field write_count = {}
---@field insert_times = {}
---@field buf_enter_count = {}
local ReporterData = {}
ReporterData.__index = ReporterData

function ReporterData.new()
    return setmetatable({
        motions = {},
        commands = {},
        write_count = {},
        insert_times = {},
        buf_enter_count = {},
    }, ReporterData)
end

---@param motion APMMotionItem
function ReporterData:motion(motion)
    local key = networkutils
    self.motions
end

