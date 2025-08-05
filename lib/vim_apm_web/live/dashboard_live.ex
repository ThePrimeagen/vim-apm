defmodule VimApmWeb.DashboardLive do
  use VimApmWeb, :live_view

  @topic "server:messages"

  def mount(%{"dashboard_id" => dashboard_id}, _session, socket) do
    case VimApm.Twitch.get_user_by_dashboard(dashboard_id) do
      nil -> {:ok, push_navigate(socket, to: ~p"/")} # does this work with live view???
      user ->
        if connected?(socket) do
          Phoenix.PubSub.subscribe(VimApm.PubSub, @topic)
        end
        {:ok, assign(socket, motion_count: 0)}
    end
  end

  def handle_info({:motion, _motion}, socket) do
    {:noreply, socket
      |> assign(motion_count: socket.assigns.motion_count + 1)
      |> push_event(@topic, %{type: "motion", motion_count: socket.assigns.motion_count})
    }
  end

end

