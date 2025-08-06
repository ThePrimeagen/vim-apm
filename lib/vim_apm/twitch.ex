# i don't really know what i am doing here.
# i am just trying things out to see how it feels.
# and hopefully get a touch better at ecto which is nuts btw
defmodule VimApm.Twitch do
  import Ecto.Query, warn: false

  defp create_token(twitch_id) do
    token = Ecto.UUID.generate()
    dashboard = Ecto.UUID.generate()
    VimApm.Tokens.create_token(%{twitch_id: twitch_id, token: token, dashboard: dashboard})

    {:ok, token, dashboard}
  end

  defp create_user(%{id: twitch_id, display_name: display_name}) do
    {:ok, user} = VimApm.Users.create_user(%{twitch_id: twitch_id, display_name: display_name})
    {:ok, token, dashboard} = create_token(twitch_id)

    {user, token, dashboard}
  end

  def get_user(%{id: twitch_id} = twitch_user) do
    user = VimApm.Repo.one(from u in VimApm.Users.User, where: u.twitch_id == ^twitch_id)
    if user == nil do
      create_user(twitch_user)
    else
      token = VimApm.Repo.one(from t in VimApm.Tokens.Token, where: t.twitch_id == ^twitch_id)
      {user, token.token, token.dashboard}
    end
  end

  def get_user_by_token(token) do
    query = from t in VimApm.Tokens.Token,
      where: t.token == ^token,
      join: u in VimApm.Users.User, on: t.twitch_id == u.twitch_id,
      select: u

    VimApm.Repo.one(query)
  end

  def get_token(%{twitch_id: twitch_id} = _) do
    VimApm.Repo.one(from t in VimApm.Tokens.Token, where: t.twitch_id == ^twitch_id)
  end

  def get_user_by_dashboard(dashboard_id) do
    query = from t in VimApm.Tokens.Token,
      where: t.dashboard == ^dashboard_id,
      join: u in VimApm.Users.User, on: t.twitch_id == u.twitch_id,
      select: u

    VimApm.Repo.one(query)
  end

  def reset_token(%{twitch_id: twitch_id}) do
    VimApm.Repo.delete_all(from t in VimApm.Tokens.Token, where: t.twitch_id == ^twitch_id)
    create_token(twitch_id)
  end

end
