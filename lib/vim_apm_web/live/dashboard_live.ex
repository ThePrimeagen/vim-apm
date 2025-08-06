defmodule VimApmWeb.DashboardLive do
  use VimApmWeb, :live_view
  alias VimApm.Motion

  @topic "server:messages"

  def mount(%{"dashboard_id" => dashboard_id}, _session, socket) do
    case VimApm.Twitch.get_user_by_dashboard(dashboard_id) do
      # does this work with live view???
      nil ->
        {:ok, push_navigate(socket, to: ~p"/")}

      user ->
        if connected?(socket) do
          Phoenix.PubSub.subscribe(VimApm.PubSub, @topic)
          :timer.send_after(5000, :tick)
        end

        {:ok,
         socket
         |> assign(motion_count: 0)
         |> assign(motion: Motion.new(max_age: 69_000))}
    end
  end

  def handle_info({:message, message}, socket) do
    motion = socket.assigns.motion
    motion = Motion.add(motion, message, System.system_time(:millisecond))

    {:noreply,
     socket
     |> assign(motion_count: socket.assigns.motion_count + 1)
     |> assign(motion: motion)
     |> push_event(@topic, %{type: "server-message", message: message})}
  end

  def handle_info(:tick, socket) do
    apm = Motion.calculate_apm(socket.assigns.motion)

    {:noreply,
     socket
     |> push_event(@topic, %{
       type: "server-message",
       message: %{
         type: "apm_report",
         value: apm
       }
     })}
  end
end
