defmodule VimApmWeb.StatsController do
  use VimApmWeb, :controller

  def index(conn, _params) do
    user = get_session(conn, :user)
    tokens = get_session(conn, :tokens)

    if user == nil || tokens == nil do
      conn |> redirect(to: "/")
    else
      render(conn, :index, layout: false, tokens: tokens, current_user: user)
    end

  end
end

