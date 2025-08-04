defmodule VimApm.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :twitch_id, :string
      add :display_name, :string

      create index(:users, [:twitch_id])

      timestamps(type: :utc_datetime)
    end
  end
end
