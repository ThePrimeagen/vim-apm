defmodule VimApm.Motion.Stat do
  defstruct type: :motion, value: "", apm: 0
end

defmodule VimApm.Motion do
  alias VimApm.CountQueue
  alias VimApm.TimeQueue

  defstruct last_motions: CountQueue.new(max: 3),
            motions: TimeQueue.new(max_age: 60_000),
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
    max_age = Keyword.get(args, :max_age, 60 * 1000)
    last_motion_count = Keyword.get(args, :last_motion_count, Application.fetch_env!(:vim_apm, :motion_last_few))

    %__MODULE__{
      max_age: max_age,
      motions: TimeQueue.new(max_age: max_age),
      last_motions: CountQueue.new(max: last_motion_count)
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
    count = CountQueue.count(motion.last_motions, chars)
    reduction = in_window * 0.01 + count * 0.25
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

  defp remove_motions(%__MODULE__{} = motion, []) do
    motion
  end

  defp remove_motions(%__MODULE__{} = motion, [stat | tl]) do
    count = Map.get(motion.motion_times, stat.value, 1) - 1
    motion_times = Map.put(motion.motion_times, stat.value, count)

    motion = %VimApm.Motion{
      motion
      | length: motion.length - 1,
        apm: motion.apm - stat.apm,
        motion_times: motion_times
    }

    remove_motions(motion, tl)
  end

  def add(motion, %{"type" => "mode_times", "value" => mode_values}, now) do
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
  end

  def add(motion, %{"type" => "motion", "value" => %{"chars" => chars}}, now) do
    motion_times =
      Map.put(motion.motion_times, chars, Map.get(motion.motion_times, chars, 0) + 1)

    apm = get_apm(motion, chars)

    {last_motions, _} = CountQueue.add(motion.last_motions, chars)
    {motions, removed} = TimeQueue.add(motion.motions, %Stat{type: :motion, value: chars, apm: apm}, now)

    motion = %VimApm.Motion{
      motion
      | motions: motions,
        motion_times: motion_times,
        apm: motion.apm + apm,
        length: motion.length + 1,
        last_motions: last_motions
    }

    remove_motions(motion, removed)
  end

  def add(motion, %{"type" => "write"}, now) do
    {motions, removed} = TimeQueue.add(motion.motions, %Stat{type: :write, value: ""}, now)
    motion = %VimApm.Motion{
      motion
      | motions: motions
    }
    remove_motions(motion, removed)
  end

  def add(motion, %{"type" => "buf_enter"}, now) do
    {motions, removed} = TimeQueue.add(motion.motions, %Stat{type: :buf_enter, value: ""}, now)
    motion = %VimApm.Motion{
      motion
      | motions: motions
    }
    remove_motions(motion, removed)
  end

  def add(motion, %{"type" => "insert_report", "value" => %{"time" => _time, "raw_typed" => _raw_typed, "changed" => _changed}}, _now) do
    motion
  end

  def add(motion, %{"type" => "apm_state_change", "value" => _value}, _now) do
    motion
  end

  def add(motion, unknown_vim_motion, _now) do
    IO.inspect(unknown_vim_motion, label: "unknown vim message")
    motion
  end

end
