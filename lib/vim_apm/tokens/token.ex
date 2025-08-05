defmodule VimApm.Tokens.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field :token, :string
    field :twitch_id, :string
    field :dashboard, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:twitch_id, :token, :dashboard])
    |> validate_required([:twitch_id, :token, :dashboard])
  end
end
