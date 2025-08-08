defmodule VimApm.Apm do
  defstruct progress: 0,
            level: 1,
            last_update: 0,
            last_set_progress: 0,
            last_motion: "",
            last_motion_count: 0,
            level_time: 0

  def new(args) do
    %__MODULE__{
      level_time: Keyword.get(args, :level_time, Application.fetch_env!(:vim_apm, :level_time))
    }
  end

  def get_next_progress(%__MODULE__{} = _apm) do
  end

  def reset_level(%__MODULE__{} = apm) do
    %__MODULE__{
      apm
      | progress: 0,
        level: 1,
        last_set_progress: 0,
        last_update: 0,
        last_motion: "",
        last_motion_count: 0
    }
  end

  defp calculate_progress_reduction(%__MODULE__{} = apm, now) do
    delta = now - apm.last_update
    percent = min(1, delta / apm.level_time)
    next_progress = apm.last_set_progress * (1 - percent)

    if next_progress <= 0.001 do
      reset_level(apm)
    else
      %VimApm.Apm{
        apm
        | progress: next_progress
      }
    end
  end

  defp level_up(%__MODULE__{} = apm) do
    add = 1 / (apm.level * 10)
    progress = apm.progress + add

    {progress, level} =
      if progress > 1 do
        {add, apm.level + 1}
      else
        {progress, apm.level}
      end

    %VimApm.Apm{
      apm
      | progress: progress,
        level: level
    }
  end

  defp set_progress(%__MODULE__{} = apm, now) do
    %VimApm.Apm{
      apm
      | last_set_progress: apm.progress,
        last_update: now
    }
  end

  defp set_last_motion(%__MODULE__{} = apm, chars) do
    {last_motion, count} =
      if apm.last_motion == chars do
        {apm.last_motion, apm.last_motion_count + 1}
      else
        {chars, 1}
      end

    %VimApm.Apm{
      apm
      | last_motion: last_motion,
        last_motion_count: count
    }
  end

  def handle_server_message(
        %__MODULE__{} = apm,
        %{"type" => "motion", "value" => %{"chars" => chars}},
        now
      ) do

    apm
      |> calculate_progress_reduction(now)
      |> level_up()
      |> set_progress(now)
      |> set_last_motion(chars)
  end

  def handle_server_message(%__MODULE__{} = apm, _message, _now) do
    apm
  end
end
