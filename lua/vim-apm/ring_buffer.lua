--- TODO: When nightly becomes a tagged release investigate vim.ringbuf and
--- see if we can remove this code and its associated tests.

---@class APMRingBuffer
---@field _start number
---@field _stop number
---@field _size number
---@field _buffer any[]
---@field len number
---@field original_size number
local APMRingBuffer = {}
APMRingBuffer.__index = APMRingBuffer

---@param size number | nil
function APMRingBuffer.new(size)
    return setmetatable({
        _buffer = {},
        _start = 1,
        _stop = 1,
        _size = size or 1000,
        len = 0,
        original_size = size or 1000,
    }, APMRingBuffer)
end

---@return any | nil
function APMRingBuffer:peek()
    return self._buffer[self._start]
end

---@param item any
function APMRingBuffer:push(item)
    self._buffer[self._stop] = item
    self._stop = self._stop + 1

    if self._stop > self._size then
        self._stop = 1
    end

    if self._stop == self._start then
        self:_resize()
    end
    self.len = self.len + 1
end

---@return any | nil
function APMRingBuffer:pop()
    if self._start == self._stop then
        return nil
    end

    local item = self._buffer[self._start]
    self._buffer[self._start] = nil
    self._start = self._start + 1

    if self._start > self._size then
        self._start = 1
    end

    self.len = self.len - 1
    return item
end

function APMRingBuffer:_resize()
    local next_size = self._size * 2
    local next_buffer = {}

    if self._start > self._stop then
        for i = self._start, self._size do
            next_buffer[i - self._start] = self._buffer[i]
        end

        local start = self._size - self._start
        for i = 1, self._stop do
            next_buffer[i + start] = self._buffer[i]
        end
    else
        for i = self._start, self._stop do
            next_buffer[i - self._start] = self._buffer[i]
        end
    end

    self._buffer = next_buffer
    self._start = 1
    self._stop = self._size
    self._size = next_size
end

function APMRingBuffer:clear()
    self._buffer = {}
    self._start = 1
    self._stop = 1
    self.len = 0
    self.size = self.original_size
end

return APMRingBuffer
