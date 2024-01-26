---@class ApmLogger
---@field _indent number
local Logger = {}
Logger.__index = Logger

function Logger.new()
    return setmetatable({
        _indent = 0,
    }, Logger)
end

function Logger:log(...)
    local args = { ... }
    for i = 1, #args do
        if type(args[i]) == "table" then
            args[i] = vim.inspect(args[i])
        else
            args[i] = tostring(args[i])
        end
    end

    local indent = string.rep(" ", self._indent)
    local str = table.concat(args, " ")
    print(indent .. str)
end

function Logger:reset()
    self._indent = 0
end

function Logger:indent()
    self._indent = self._indent + 2
end

function Logger:dedent()
    self._indent = self._indent - 2
end

return Logger:new()
