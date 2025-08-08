defmodule VimApm.TimeQueue do
  defstruct buffer: :queue.new(), max_age: 60_000, length: 0

  def new(args) do
    %__MODULE__{
      max_age: Keyword.get(args, :max_age, 60_000)
    }
  end

  defp remove_old(%__MODULE__{} = queue, removed, now) do
    with {:value, front} <- :queue.peek(queue.buffer) do
      if now - front.time > queue.max_age do
        removed = [front.value | removed]
        queue = %VimApm.TimeQueue{
          queue
          | buffer: :queue.drop(queue.buffer),
            length: queue.length - 1,
        }

        remove_old(queue, removed, now)
      else
        {queue, removed}
      end
    else
      _ -> {queue, removed}
    end
  end

  def add(%__MODULE__{} = queue, value, now) do
    queue = %VimApm.TimeQueue{
      queue
      | buffer: :queue.in(%{time: now, value: value}, queue.buffer),
        length: queue.length + 1,
    }
    remove_old(queue, [], now)
  end

end

