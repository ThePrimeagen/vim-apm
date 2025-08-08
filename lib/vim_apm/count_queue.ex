defmodule VimApm.CountQueue do
  defstruct buffer: :queue.new(), max: 0, length: 0

  def new(args) do
    max = Keyword.get(args, :max, 3)
    %__MODULE__{max: max}
  end

  def add(%__MODULE__{} = queue, value) do
    buffer = :queue.in(value, queue.buffer)

    if queue.length + 1 > queue.max do
      out = case :queue.peek(buffer) do
        {:value, value} -> value
        _ -> nil
      end
      buffer = :queue.drop(buffer)
      {%__MODULE__{queue | buffer: buffer, length: queue.max}, out}
    else
      {%__MODULE__{queue | buffer: buffer, length: queue.length + 1}, nil}
    end
  end
end
