defmodule VimApmWeb.TestLive do
  use VimApmWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(VimApm.PubSub, "server:messages")
    end

    level_time = Application.fetch_env!(:vim_apm, :level_time)

    {:ok,
     assign(socket,
       motion: "none",
       motion_count: 0,
       apm: VimApm.Apm.new(),
       level_time: level_time,
       proress: 0.0
     )}
  end

  defp update_apm(socket, message) do
    assign(socket,
      apm:
        VimApm.Apm.handle_server_message(
          socket.assigns.apm,
          message,
          System.system_time(:millisecond)
        )
    )
  end

  defp process_message(socket, message) do
    case message do
      %{"type" => "motion", "value" => %{"chars" => chars}} ->
        assign(socket, motion: chars, motion_count: socket.assigns.motion_count + 1)

      _ ->
        socket
    end
  end

  defp upgrade_progress(socket) do
    assign(socket, progress: socket.assigns.apm.progress)
  end

  def handle_info({:message, message}, socket) do
    socket =
      socket
      |> update_apm(message)
      |> process_message(message)
      |> upgrade_progress()

    {:noreply, socket}
  end

  def handle_event("test", _params, socket) do
    {:noreply, socket}
  end
end
