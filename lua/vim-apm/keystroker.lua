local trackedStrokes = {
    "di*",
    "df*",
    "dt*",
    "da*",
    "ci*",
    "cf*",
    "ct*",
    "ca*",
    "S",
    "c$",
    "cw",
    "d*i",
}

local file = io.open("/home/mpaulson/apm.log", "a")
local function join(arr)
    if arr == nil then
        return ""
    end

    local str = ""
    for idx = 1, #arr do
        str = str .. " " .. arr[idx]
    end

    return str
end
local function printr(...)
    file:write("\n")
    file:write(join({...}))
    file:flush()
end

local KeyStroker = {}

function KeyStroker:new()
    local keyStroke = {
        trackedSlotIdx = -1,
        typedItems = {},
        tracked = {},
        startTime = vim.fn.reltimefloat(vim.fn.reltime()),
        file = io.open("/home/mpaulson/apm.csv", "a"),
    }

    self.__index = self
    return setmetatable(keyStroke, self)
end

function KeyStroker:reset()
    self.trackedSlotIdx = 1
    self.typedItems = {}
    self.startTime = vim.fn.reltimefloat(vim.fn.reltime())
    self.tracked = {}

    for idx = 1, #trackedStrokes do
        table.insert(self.tracked, trackedStrokes[idx])
    end
end

function KeyStroker:onNormal()
    self.mode = "normal"
    self:reset()
end

function KeyStroker:testTracked()
    printr("attempting to testTracked", self.trackedSlotIdx, #self.tracked)
    local now = vim.fn.reltimefloat(vim.fn.reltime())

    if #self.tracked ~= 1 then
        return
    end

    local item = self.tracked[1]
    if #item + 1 ~= self.trackedSlotIdx then
        return
    end

    printr("Writing", item, join(self.typedItems), now - self.startTime)
    self.file:write("\n")
    self.file:write(item)
    self.file:write(",")
    self.file:write(join(self.typedItems))
    self.file:write(",")
    self.file:write(now - self.startTime)
    self.file:flush()
end

function KeyStroker:onInsert()
    self.mode = "insert"
end

function KeyStroker:onKey(key)
    if self.mode == "insert" and self.trackedIdx ~= -1 then
        self:testTracked()
        self:reset()
        return
    end

    local tracked = {}
    for idx = 1, #self.tracked do
        local item = self.tracked[idx]
        local letter = string.sub(item, self.trackedSlotIdx, self.trackedSlotIdx)
        printr("testing letter", idx, letter, key)
        if letter == key or letter == "*" then
            printr("found letter", letter)
            table.insert(tracked, item)
        end
    end
    self.tracked = tracked

    if #self.tracked > 0 then
        printr("success tracked")
        self.trackedSlotIdx = self.trackedSlotIdx + 1
        table.insert(self.typedItems, key)
    else
        printr("resetting tracked")
        self:reset()
    end

end

return KeyStroker
