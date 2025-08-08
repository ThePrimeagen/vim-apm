defmodule VimApm.Motion.Stat do
  defstruct type: :motion, value: "", apm: 0
end

defmodule VimApm.Motion do
  alias VimApm.CountQueue
  alias VimApm.TimeQueue

  defstruct last_motions: CountQueue.new(max: 3),
            motions: TimeQueue.new(max_age: 60_000),
            motion_times: %{},
            modes: TimeQueue.new(max_age: 60_000),
            mode_times: %{
              "n" => 0,
              "i" => 0,
              "v" => 0,
              "untracked" => 0
            },
            max_age: 60 * 1000,
            apm: 0,
            cpm_times: TimeQueue.new(max_age: 60_000),
            cpm_raw: 0,
            cpm_changed: 0,
            time_in_insert: 0,
            length: 0

  alias VimApm.Motion.Stat

  def new(args) do
    max_age = Keyword.get(args, :max_age, 60 * 1000)

    last_motion_count =
      Keyword.get(args, :last_motion_count, Application.fetch_env!(:vim_apm, :motion_last_few))

    %__MODULE__{
      max_age: max_age,
      motions: TimeQueue.new(max_age: max_age),
      modes: TimeQueue.new(max_age: max_age),
      last_motions: CountQueue.new(max: last_motion_count),
      cpm_times: TimeQueue.new(max_age: max_age)
    }
  end

  def calculate_total_apm(motion) do
    minutes = motion.max_age / 60_000.0
    cpw = Application.fetch_env!(:vim_apm, :characters_per_word)
    apm = Float.round(motion.apm / minutes, 2)
    raw = Float.round(motion.cpm_raw / cpw / minutes, 2)
    changed = Float.round(motion.cpm_changed / cpw / minutes, 2)

    IO.inspect("apm: #{apm}, raw: #{raw}, changed: #{changed}", label: "total_apm")
    {apm + raw, apm, raw, changed}
  end

  def calculate_mode_times(motion) do
    Enum.reduce(motion.modes, %{}, fn {mode, time}, acc ->
      nil
    end)
  end

  defp get_apm(_motion, _chars) do
    1
  end

  defp remove_modes(%__MODULE__{} = motion, []) do
    motion
  end

  defp remove_modes(%__MODULE__{} = motion, [mode | tl]) do
    mode_times =
      Enum.reduce(mode, motion.mode_times, fn {mode, time}, acc ->
        Map.put(acc, mode, Map.get(acc, mode, 0) - time)
      end)

    remove_modes(%VimApm.Motion{motion | mode_times: mode_times}, tl)
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

  defp remove_cpm_times(%__MODULE__{} = motion, []) do
    motion
  end

  defp remove_cpm_times(%__MODULE__{} = motion, [insert_report | tl]) do
    %{"time" => time, "raw_typed" => raw_typed, "changed" => changed} = insert_report

    remove_cpm_times(%VimApm.Motion{
      motion
      | cpm_raw: motion.cpm_raw - raw_typed,
        cpm_changed: motion.cpm_changed - changed,
        time_in_insert: motion.time_in_insert - time
    }, tl)
  end

  def add(motion, %{"type" => "mode_times", "value" => mode_values}, now) do
    mode_times =
      Enum.reduce(mode_values, motion.mode_times, fn {mode, time}, acc ->
        Map.put(acc, mode, Map.get(acc, mode, 0) + time)
      end)

    {modes, removed} = TimeQueue.add(motion.modes, mode_values, now)

    remove_modes(
      %VimApm.Motion{
        motion
        | mode_times: mode_times,
          modes: modes
      },
      removed
    )
  end

  def add(motion, %{"type" => "motion", "value" => %{"chars" => chars}}, now) do
    motion_times =
      Map.put(motion.motion_times, chars, Map.get(motion.motion_times, chars, 0) + 1)

    apm = get_apm(motion, chars)
    IO.inspect("added apm: #{apm} with current total as #{motion.apm}", label: "add_motion")

    {last_motions, _} = CountQueue.add(motion.last_motions, chars)

    {motions, removed} =
      TimeQueue.add(motion.motions, %Stat{type: :motion, value: chars, apm: apm}, now)

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

  def add(%__MODULE__{} = motion, %{"type" => "insert_report", "value" => value}, now) do
    %{"time" => time, "raw_typed" => raw_typed, "changed" => changed} = value
    {cpm_times, removed} = TimeQueue.add(motion.cpm_times, value, now)

    motion = %VimApm.Motion{
      motion
      | cpm_times: cpm_times,
        cpm_raw: motion.cpm_raw + raw_typed,
        cpm_changed: motion.cpm_changed + changed,
        time_in_insert: motion.time_in_insert + time
    }

    remove_cpm_times(motion, removed)
  end

  def add(motion, %{"type" => "apm_state_change", "value" => _value}, _now) do
    motion
  end

  def add(motion, unknown_vim_motion, _now) do
    IO.inspect(unknown_vim_motion, label: "unknown vim message")
    motion
  end
end
