defmodule VimApmWeb.PageController do
  use VimApmWeb, :controller

  def home(conn, _params) do
    user = get_session(conn, :user)
    render(conn, :home, layout: false, current_user: user, login_path: ~p"/auth/twitch")
  end
end
