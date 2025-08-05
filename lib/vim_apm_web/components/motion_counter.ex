defmodule VimApmWeb.Components.MotionCounter do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div>
      WHAT IS THIS REACT??? {assigns.motion_count}
    </div>
    """
  end

end

