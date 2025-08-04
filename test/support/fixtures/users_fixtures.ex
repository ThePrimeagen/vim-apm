defmodule VimApm.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VimApm.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        display_name: "some display_name",
        twitch_id: "some twitch_id"
      })
      |> VimApm.Users.create_user()

    user
  end
end
