defmodule VimApm.CountQueueTest do
  use VimApm.DataCase

  alias VimApm.CountQueue

  describe "add" do
    test "ensures max is enforced" do
      queue = CountQueue.new(max: 2)

      {queue, nil} = CountQueue.add(queue, {"w1"})
      assert queue.length == 1

      {queue, nil} = CountQueue.add(queue, {"w2"})
      assert queue.length == 2

      {queue, {"w1"}} = CountQueue.add(queue, {"w3"})
      assert queue.length == 2

      {queue, {"w2"}} = CountQueue.add(queue, {"w4"})
      assert queue.length == 2
    end
  end
end


