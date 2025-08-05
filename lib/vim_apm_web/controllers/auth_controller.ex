defmodule VimApmWeb.AuthController do
  use VimApmWeb, :controller
  alias VimApm.OAuth.Twitch

  def request(conn, _params) do
    IO.inspect("redirecting to twitch login", label: "twitch request")
    redirect(conn, external: Twitch.authorize_url!())
  end

  def reset_token(conn, _params) do
    user = get_session(conn, :user)
    case VimApm.Twitch.reset_token(user) do
      {:ok, _} -> conn |> put_flash(:info, "Token Reset!") |> redirect(to: "/")
      {:error, _} -> conn |> put_flash(:error, "Error Resetting Token!") |> redirect(to: "/")
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

    user = VimApm.Twitch.get_user(user)

    conn
    |> put_session(:user, user)
    |> redirect(to: "/")
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "No code received from Twitch")
    |> redirect(to: "/")
  end
end
