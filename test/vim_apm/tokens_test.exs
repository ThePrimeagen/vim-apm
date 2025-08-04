defmodule VimApm.TokensTest do
  use VimApm.DataCase

  alias VimApm.Tokens

  describe "tokens" do
    alias VimApm.Tokens.Token

    import VimApm.TokensFixtures

    @invalid_attrs %{token: nil, twitch_id: nil}

    test "list_tokens/0 returns all tokens" do
      token = token_fixture()
      assert Tokens.list_tokens() == [token]
    end

    test "get_token!/1 returns the token with given id" do
      token = token_fixture()
      assert Tokens.get_token!(token.id) == token
    end

    test "create_token/1 with valid data creates a token" do
      valid_attrs = %{token: "some token", twitch_id: "some twitch_id"}

      assert {:ok, %Token{} = token} = Tokens.create_token(valid_attrs)
      assert token.token == "some token"
      assert token.twitch_id == "some twitch_id"
    end

    test "create_token/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tokens.create_token(@invalid_attrs)
    end

    test "update_token/2 with valid data updates the token" do
      token = token_fixture()
      update_attrs = %{token: "some updated token", twitch_id: "some updated twitch_id"}

      assert {:ok, %Token{} = token} = Tokens.update_token(token, update_attrs)
      assert token.token == "some updated token"
      assert token.twitch_id == "some updated twitch_id"
    end

    test "update_token/2 with invalid data returns error changeset" do
      token = token_fixture()
      assert {:error, %Ecto.Changeset{}} = Tokens.update_token(token, @invalid_attrs)
      assert token == Tokens.get_token!(token.id)
    end

    test "delete_token/1 deletes the token" do
      token = token_fixture()
      assert {:ok, %Token{}} = Tokens.delete_token(token)
      assert_raise Ecto.NoResultsError, fn -> Tokens.get_token!(token.id) end
    end

    test "change_token/1 returns a token changeset" do
      token = token_fixture()
      assert %Ecto.Changeset{} = Tokens.change_token(token)
    end
  end
end
