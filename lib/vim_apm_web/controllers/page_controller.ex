defmodule VimApmWeb.PageController do
  use VimApmWeb, :controller

  def home(conn, _params) do
    user = get_session(conn, :user)
    tokens = get_session(conn, :tokens)

    render(conn, :home, layout: false, tokens: tokens, current_user: user, login_path: ~p"/auth/twitch")
  end
end
