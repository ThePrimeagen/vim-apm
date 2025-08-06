defmodule VimApm.Motion.Stat do
  defstruct time: 0, type: :motion, value: "", apm: 0
end

defmodule VimApm.Motion do
  defstruct stats: :queue.new(), max_age: 60 * 1000, motions: %{}, apm: 0, length: 0

  alias VimApm.Motion.Stat

  def new(args) do
    %__MODULE__{
      max_age: Keyword.get(args, :max_age, 60 * 1000)
    }
  end

  def calculate_apm(motion) do
    minutes = motion.max_age / 60_000.0
    motion.apm / minutes
  end

  defp get_motion_count(motion, chars) do
    case Map.get(motion.motions, chars) do
      nil -> 1
      count -> count + 1
    end
  end

  defp get_apm(_motion, _chars) do
    1
  end

  defp remove_old(motion, now) do
    with {:value, front} <- :queue.peek(motion.stats) do
      if now - front.time > motion.max_age do
        motion = %VimApm.Motion{
          motion
          | stats: :queue.drop(motion.stats),
            length: motion.length - 1,
            apm: motion.apm - front.apm
        }

        remove_old(motion, now)
      else
        motion
      end
    else
      _ -> motion
    end
  end

  def add(motion, vim_message, now) do
    motion =
      case vim_message do
        %{type: "motion", value: %{chars: chars}} ->
          motions = Map.put(motion.motions, chars, get_motion_count(motion, chars))
          apm = get_apm(motion, chars)

          remove_old(%VimApm.Motion{
            motion
            | stats: :queue.in(%Stat{time: now, type: :motion, value: chars, apm: apm}, motion.stats),
              motions: motions,
              apm: motion.apm + apm,
              length: motion.length + 1
          }, now)

        %{type: "write"} ->
          :queue.in(%Stat{time: now, type: :write, value: ""}, motion.stats)

        %{type: "buf_enter"} ->
          :queue.in(%Stat{time: now, type: :write, value: ""}, motion.stats)

        _ ->
          IO.inspect(vim_message, label: "unknown vim message")
      end

    remove_old(motion, now)
  end
end
