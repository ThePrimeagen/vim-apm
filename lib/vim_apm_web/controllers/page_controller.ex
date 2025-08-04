defmodule VimApmWeb.PageController do
  use VimApmWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false, current_user: nil, login_path: ~p"/auth/twitch")
  end
end
