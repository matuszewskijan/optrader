defmodule Optrader.Repo.Migrations.CreateGoogleTrends do
  use Ecto.Migration

  def change do
    create table(:google_trends) do
      add :currency_name, :string
      add :currency_short_name, :string
      add :value, :integer
      add :interval_number, :integer
      add :interval_unit, :string
      add :time, :naive_datetime

      timestamps()
    end

  end
end
