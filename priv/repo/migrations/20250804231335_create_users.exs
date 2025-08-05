defmodule VimApm.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :twitch_id, :string
      add :display_name, :string

      timestamps(type: :utc_datetime)
    end
    create index(:users, [:twitch_id])
  end
end
