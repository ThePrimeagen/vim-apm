defmodule VimApm.Motion.Stat do
  defstruct time: 0, type: :motion, value: "", apm: 0
end

defmodule VimApm.Motion do
  defstruct last_motions: :queue.new(),
            stats: :queue.new(),
            max_age: 60 * 1000,
            motions: %{},
            apm: 0,
            length: 0

  alias VimApm.Motion.Stat

  def new(args) do
    %__MODULE__{
      max_age: Keyword.get(args, :max_age, 60 * 1000)
    }
  end

  def calculate_apm(motion) do
    minutes = motion.max_age / 60_000.0
    Float.round(motion.apm / minutes, 2)
  end

  defp get_apm(motion, chars) do
    in_window = Map.get(motion.motions, chars, 0)
    last_four = :queue.fold(fn item, acc ->
      if item == chars do
        acc + 1
      else
        acc
      end
    end, 0, motion.last_motions)

    IO.inspect("last_four #{last_four * 0.25}", label: "get_apm")
    reduction = in_window * 0.01 + last_four * 0.25
    max(1 - reduction, 0.01)
  end

  defp remove_old(motion, now) do
    with {:value, front} <- :queue.peek(motion.stats) do
      if now - front.time > motion.max_age do
        # there has to be a better way of doing this...
        count = Map.get(motion.motions, front.value, 1) - 1
        motions = Map.put(motion.motions, front.value, count)

        motion = %VimApm.Motion{
          motion
          | stats: :queue.drop(motion.stats),
            length: motion.length - 1,
            apm: motion.apm - front.apm,
            motions: motions
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
    case vim_message do
      %{"type" => "motion", "value" => %{"chars" => chars}} ->
        motions = Map.put(motion.motions, chars, Map.get(motion.motions, chars, 0) + 1)
        apm = get_apm(motion, chars)

        last_motions = :queue.in(chars, motion.last_motions)

        if :queue.len(last_motions) > Application.fetch_env!(:vim_apm, :motion_last_few) do
          :queue.drop(last_motions)
        end

        motion = %VimApm.Motion{
          motion
          | stats:
              :queue.in(%Stat{time: now, type: :motion, value: chars, apm: apm}, motion.stats),
            motions: motions,
            apm: motion.apm + apm,
            length: motion.length + 1,
            last_motions: last_motions
        }

        remove_old(motion, now)

      %{"type" => "write"} ->
        %VimApm.Motion{
          motion
          | stats: :queue.in(%Stat{time: now, type: :write, value: ""}, motion.stats)
        }

      %{"type" => "buf_enter"} ->
        %VimApm.Motion{
          motion
          | stats: :queue.in(%Stat{time: now, type: :write, value: ""}, motion.stats)
        }

      %{"type" => "apm_state_change", "value" => value} ->
          IO.inspect(value, label: "apm_state_change")
          motion
      _ ->
        IO.inspect(vim_message, label: "unknown vim message")
    end
  end
end
