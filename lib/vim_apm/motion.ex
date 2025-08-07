defmodule VimApm.Motion.Stat do
  defstruct time: 0, type: :motion, value: "", apm: 0
end

defmodule VimApm.Motion do
  defstruct last_motions: :queue.new(),
            motions: :queue.new(),
            motion_times: %{},
            modes: :queue.new(),
            mode_times: %{
              "n" => 0,
              "i" => 0,
              "v" => 0,
              "untracked" => 0
            },
            max_age: 60 * 1000,
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

  def calculate_mode_times(motion) do
    Enum.reduce(motion.modes, %{}, fn {mode, time}, acc ->
      nil
    end)
  end

  defp get_apm(motion, chars) do
    in_window = Map.get(motion.motion_times, chars, 0)

    last_four =
      :queue.fold(
        fn item, acc ->
          if item == chars do
            acc + 1
          else
            acc
          end
        end,
        0,
        motion.last_motions
      )

    reduction = in_window * 0.01 + last_four * 0.25
    max(1 - reduction, 0.01)
  end

  defp remove_modes(motion, now) do
    with {:value, front} <- :queue.peek(motion.modes) do
      if now - front.time > motion.max_age do
        modes = :queue.drop(motion.modes)
        mode_times =
          Enum.reduce(front, motion.mode_times, fn {mode, time}, acc ->
            # remember, we add a time field to the mode map.  this is annoying
            # and causes unit tests to fail :(
            if mode == :time do
              acc
            else
              Map.put(acc, mode, Map.get(acc, mode, 0) - time)
            end
          end)

        remove_modes(%VimApm.Motion{motion | mode_times: mode_times, modes: modes}, now)
      else
        motion
      end
    else
      _ -> motion
    end
  end

  defp remove_motions(motion, now) do
    with {:value, front} <- :queue.peek(motion.motions) do
      if now - front.time > motion.max_age do
        # there has to be a better way of doing this...
        count = Map.get(motion.motion_times, front.value, 1) - 1
        motion_times = Map.put(motion.motion_times, front.value, count)

        motion = %VimApm.Motion{
          motion
          | motions: :queue.drop(motion.motions),
            length: motion.length - 1,
            apm: motion.apm - front.apm,
            motion_times: motion_times
        }

        remove_motions(motion, now)
      else
        motion
      end
    else
      _ -> motion
    end
  end

  def add(motion, vim_message, now) do
    case vim_message do
      %{"type" => "mode_times", "value" => mode_values} ->
        timed_mode_values = Map.put(mode_values, :time, now)
        modes = :queue.in(timed_mode_values, motion.modes)

        mode_times =
          Enum.reduce(mode_values, motion.mode_times, fn {mode, time}, acc ->
            Map.put(acc, mode, Map.get(acc, mode, 0) + time)
          end)

        remove_modes(
          %VimApm.Motion{
            motion
            | mode_times: mode_times,
              modes: modes
          },
          now
        )

      %{"type" => "motion", "value" => %{"chars" => chars}} ->
        motion_times =
          Map.put(motion.motion_times, chars, Map.get(motion.motion_times, chars, 0) + 1)

        apm = get_apm(motion, chars)

        last_motions = :queue.in(chars, motion.last_motions)

        if :queue.len(last_motions) > Application.fetch_env!(:vim_apm, :motion_last_few) do
          :queue.drop(last_motions)
        end

        motion = %VimApm.Motion{
          motion
          | motions:
              :queue.in(%Stat{time: now, type: :motion, value: chars, apm: apm}, motion.motions),
            motion_times: motion_times,
            apm: motion.apm + apm,
            length: motion.length + 1,
            last_motions: last_motions
        }

        remove_motions(motion, now)

      %{"type" => "write"} ->
        %VimApm.Motion{
          motion
          | motions: :queue.in(%Stat{time: now, type: :write, value: ""}, motion.motions)
        }

      %{"type" => "buf_enter"} ->
        %VimApm.Motion{
          motion
          | motions: :queue.in(%Stat{time: now, type: :write, value: ""}, motion.motions)
        }

      %{"type" => "apm_state_change", "value" => value} ->
        motion

      _ ->
        IO.inspect(vim_message, label: "unknown vim message")
    end

  end
end
