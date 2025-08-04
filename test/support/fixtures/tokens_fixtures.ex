defmodule VimApm.TokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VimApm.Tokens` context.
  """

  @doc """
  Generate a token.
  """
  def token_fixture(attrs \\ %{}) do
    {:ok, token} =
      attrs
      |> Enum.into(%{
        token: "some token",
        twitch_id: "some twitch_id"
      })
      |> VimApm.Tokens.create_token()

    token
  end
end
