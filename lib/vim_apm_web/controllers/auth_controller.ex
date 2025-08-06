defmodule VimApmWeb.AuthController do
  use VimApmWeb, :controller
  alias VimApm.OAuth.Twitch

  def request(conn, _params) do
    IO.inspect("redirecting to twitch login", label: "twitch request")
    redirect(conn, external: Twitch.authorize_url!())
  end

  def reset_token(conn, _params) do
    user = get_session(conn, :user)

    # apparently errors are just not possible?  this ... seems unlikely
    case VimApm.Twitch.reset_token(user) do
      {:ok, _, _} -> conn |> put_flash(:info, "Token Reset!") |> redirect(to: "/")
    end
  end

  def callback(conn, %{"code" => code} = out) do
    IO.inspect(out, label: "twitch callback")
    client = Twitch.get_token!(code: code)
    token = client.token
    IO.inspect(token, label: "twitch get_token:")

    user_req =
      Finch.build(:get, "https://api.twitch.tv/helix/users", [
        {"Authorization", "Bearer #{token.access_token}"},
        {"Client-Id", Application.fetch_env!(:vim_apm, :client_id)}
      ])

    user = with {:ok, %Finch.Response{status: 200, body: user_body}} <- Finch.request(user_req, VimApm.Finch),
         {:ok, %{"data" => [%{"id" => user_id, "display_name" => display_name} = user]}} <- Jason.decode(user_body) do

        IO.inspect(user, label: "fetched twitch user")

        %{id: user_id, display_name: display_name}
    else
        _ -> %{id: nil, display_name: "none"}
    end

    IO.inspect(user, label: "twitch user information")

    {user, token, dashboard} = VimApm.Twitch.get_user(user)

    conn
    |> put_session(:user, user)
    |> put_session(:tokens, %{token: token, dashboard: dashboard})
    |> redirect(to: "/")
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "No code received from Twitch")
    |> redirect(to: "/")
  end
end
