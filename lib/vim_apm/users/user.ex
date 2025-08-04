defmodule VimApm.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :twitch_id, :string
    field :display_name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:twitch_id, :display_name])
    |> validate_required([:twitch_id, :display_name])
  end
end
