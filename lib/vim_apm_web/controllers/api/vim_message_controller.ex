defmodule VimApmWeb.Api.VimMessageController do
  alias VimApm.Twitch
  use VimApmWeb, :controller

  @topic "server:messages"

  defp unauthorized(conn) do
    conn
    |> put_status(401)
    |> json(%{error: "Unauthorized"})
  end

  defp handle_message(conn, json) do
    Phoenix.PubSub.broadcast(VimApm.PubSub, @topic, {:message, json})

    conn
    |> put_status(200)
    |> json(%{message: "ok"})
  end

  def message(conn, params) do
    auth = get_req_header(conn, "authorization")

    case auth do
      ["Bearer " <> token] ->
        with nil <- Twitch.get_user_by_token(token) do
          unauthorized(conn)
        else
          user ->
            IO.inspect(params, label: "vim_message_controller#handle_message")
            handle_message(conn, params)
        end

      _ ->
        unauthorized(conn)
    end
  end
end
