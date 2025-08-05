defmodule VimApmWeb.DashboardController do
  use VimApmWeb, :controller

  defp not_found(conn) do
    conn
    |> put_status(404)
    |> json(%{error: "Not Found"})
  end

  def show(conn, %{"dashboard_id" => dashboard_id}) do
    case VimApm.Twitch.get_user_by_dashboard(dashboard_id) do
      nil -> not_found(conn)
      user ->
        IO.inspect("user: #{inspect(user)}", label: "user")
        render(conn, "show.html", dashboard_id: dashboard_id, user: user)
    end
  end
end
