defmodule VimApmWeb.Api.VimMessageController do
  alias VimApm.Twitch
  use VimApmWeb, :controller

  @topic "server:messages"

  defp unauthorized(conn) do
    conn
    |> put_status(401)
    |> json(%{error: "Unauthorized"})
  end

  defp handle_motions(conn, user) do
    IO.inspect("handle_motions: for user #{inspect(user)}", label: "handle_motions")
    # we are currently not doing anything with the motions...
    Phoenix.PubSub.broadcast(VimApm.PubSub, @topic, {:motion, "hello"})
    conn
    |> put_status(200)
    |> json(%{message: "ok"})
  end

  def motions(conn, params) do
    auth = get_req_header(conn, "authorization")

    IO.inspect(auth, label: "auth")
    case auth do
      ["Bearer " <> token] ->
        with nil <- Twitch.get_user_by_token(token) do
          unauthorized(conn)
        else
          user ->
            handle_motions(conn, user)
        end
      _ ->
        unauthorized(conn)
    end
  end
end

