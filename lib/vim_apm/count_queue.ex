defmodule VimApm.CountQueue do
  defstruct buffer: :queue.new(), max: 0, length: 0

  def new() do
    %__MODULE__{}
  end

  def add(%__MODULE__{} = queue, value) do
    buffer = :queue.in(value, queue.buffer)

    if queue.length + 1 > queue.max do
      out = :queue.drop(buffer)
      {%__MODULE__{queue | buffer: buffer, length: queue.max}, out}
    else
      {%__MODULE__{queue | buffer: buffer, length: queue.length + 1}, nil}
    end
  end
end
