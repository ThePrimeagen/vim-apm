defmodule VimApm.Tokens.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field :token, :string
    field :twitch_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:twitch_id, :token])
    |> validate_required([:twitch_id, :token])
  end
end
