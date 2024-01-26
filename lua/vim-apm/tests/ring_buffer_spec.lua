local eq = assert.are.same
local RingBuffer = require("vim-apm.ring_buffer")

describe("RingBuffer", function()
    it("non wrap operations", function()
        local buffer = RingBuffer.new(10)
        buffer:push(1)
        buffer:push(2)
        buffer:push(3)

        eq(1, buffer:pop())
        eq(2, buffer:pop())
        eq(3, buffer:pop())
        eq(nil, buffer:pop())

        eq(buffer._start, 4)
        eq(buffer._start, buffer._stop)
    end)

    it("wrap operations", function()
        local buffer = RingBuffer.new(3)
        buffer:push(1)
        buffer:push(2)

        eq(1, buffer:pop())
        eq(2, buffer._start)

        buffer:push(3)
        eq(true, buffer._start > buffer._stop)

        eq(2, buffer.len)
        eq(2, buffer:pop())
        eq(3, buffer:pop())
        eq(0, buffer.len)
    end)
end)
