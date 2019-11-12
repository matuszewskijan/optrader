defmodule Optrader.Repo.Migrations.CreateFGIndex do
  use Ecto.Migration

  def change do
    create table(:f_g_index) do
      add :value, :string
      add :value_classification, :string
      add :date, :naive_datetime

      timestamps()
    end

  end
end
