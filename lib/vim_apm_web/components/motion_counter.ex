defmodule VimApmWeb.Components.MotionCounter do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    TEST MOTION COUNTER {assigns.motion_count}
    """
  end
end

