defmodule VimApm.Repo.Migrations.AddUuidToUsers do
  use Ecto.Migration
  import Ecto.Query, warn: false

  alias VimApm.Tokens.Token

  def up do
    alter table("tokens") do
      add :dashboard, :string
    end

    flush()

    VimApm.Repo.transaction(fn ->
      VimApm.Repo.all(Token)
      |> Enum.each(fn token ->
        changeset = Ecto.Changeset.change(token, dashboard: Ecto.UUID.generate())
        VimApm.Repo.update!(changeset)
      end)
    end)

    create unique_index(:tokens, [:dashboard])
  end

  def down do
    alter table(:tokens) do
      remove :dashboard
    end
  end
end
