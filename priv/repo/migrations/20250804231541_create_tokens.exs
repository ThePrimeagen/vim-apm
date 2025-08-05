defmodule VimApm.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :twitch_id, :string
      add :token, :string


      timestamps(type: :utc_datetime)
    end

    create index(:tokens, [:twitch_id])
    create index(:tokens, [:token])

  end
end
