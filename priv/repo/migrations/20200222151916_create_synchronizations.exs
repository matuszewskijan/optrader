defmodule Optrader.Repo.Migrations.CreateSynchronizations do
  use Ecto.Migration

  def change do
    create table(:synchronizations) do
      add :service, :string
      add :imported_items, :integer

      timestamps()
    end

  end
end
