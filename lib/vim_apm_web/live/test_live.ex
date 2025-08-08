defmodule VimApmWeb.TestLive do
  use VimApmWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(VimApm.PubSub, "server:messages")
      :timer.send_interval(1000, :tick)
    end

    {:ok, assign(socket,
      motion: "none",
      motion_count: 0,
      progress: 0.5
    ) }
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, progress: socket.assigns.progress + 0.01)}
  end

  def handle_info({:message, message}, socket) do
    case message do
      %{"type" => "motion", "value" => %{"chars" => chars}} ->
        {:noreply, assign(socket, motion: chars, motion_count: socket.assigns.motion_count + 1)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("test", _params, socket) do
    {:noreply, socket}
  end
end
