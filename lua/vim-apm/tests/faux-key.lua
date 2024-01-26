local APMBussin = require("vim-apm.bus")
local Events = require("vim-apm.event_names")
local utils = require("vim-apm.utils")

---@class APMFauxKeyEvent
---@field type ON_KEY | MODE_CHANGED
---@field value string | string[]

---@param keys string
---@return APMFauxKeyEvent[]
local function create_play_keys(keys, out)
    out = out or {}
    for i = 1, #keys do
        local key = keys:sub(i, i)
        table.insert(out, {
            type = Events.ON_KEY,
            value = key,
        })
    end
    return out
end

---@class APMFauxKey
---@field operations {event: APMFauxKeyEvent[], delay: number}
local FauxKey = {}
FauxKey.__index = FauxKey

---@return APMFauxKey
function FauxKey.new()
    return setmetatable({
        operations = {},
    }, FauxKey)
end

---@param mode string[]
---@return APMFauxKey
function FauxKey:to_mode(mode, delay)
    delay = delay or 100
    table.insert(self.operations, {
        event = {
            type = Events.MODE_CHANGED,
            value = mode,
        },
        delay = delay,
    })
    return self
end

---@param keys string
---@return APMFauxKey
function FauxKey:add_keys(keys, delay)
    delay = delay or 100
    local ops = create_play_keys(keys)
    for i = 1, #ops do
        table.insert(self.operations, {
            event = ops[i],
            delay = delay,
        })
    end
    return self
end

---@return number, number, {n: number, i: number}
function FauxKey:play()
    local start_time = utils.now()
    local modes = {
        n = 0,
        i = 0,
    }

    local current_mode = "n"
    local last_mode_start_time = utils.now()

    for _, op in ipairs(self.operations) do
        local event = op.event
        local delay = op.delay

        vim.wait(delay)
        APMBussin:emit(event.type, event.value)

        if event.type == Events.MODE_CHANGED then
            local time_in_mode = (utils.now() - last_mode_start_time)
            modes[current_mode] = modes[current_mode] + time_in_mode
            last_mode_start_time = utils.now()
            current_mode = event.value[2]
        end
    end

    return start_time, utils.now() - start_time, modes
end

return FauxKey
