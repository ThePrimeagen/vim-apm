defmodule VimApm.TimeQueueTest do
  use VimApm.DataCase

  alias VimApm.TimeQueue

  describe "add" do
    test "add and drops happen" do
      queue = TimeQueue.new(max_age: 1000)

      now = 0
      {queue, removed} = TimeQueue.add(queue, {"w1"}, now)
      assert queue.length == 1
      assert [] == removed

      now = 500
      {queue, removed} = TimeQueue.add(queue, {"w2"}, now)
      assert queue.length == 2
      assert [] == removed

      now = 999
      {queue, removed} = TimeQueue.add(queue, {"w3"}, now)
      assert queue.length == 3
      assert [] == removed

      now = 1000
      {queue, removed} = TimeQueue.add(queue, {"w4"}, now)
      assert queue.length == 4
      assert [] == removed

      now = 1001
      {queue, removed} = TimeQueue.add(queue, {"w5"}, now)
      assert queue.length == 4
      assert [{"w1"}] == removed

      now = 2001
      {queue, removed} = TimeQueue.add(queue, {"w6"}, now)
      assert queue.length == 2
      assert [{"w4"}, {"w3"}, {"w2"}] == removed
    end
  end
end

