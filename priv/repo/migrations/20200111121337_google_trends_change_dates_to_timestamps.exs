defmodule Optrader.Repo.Migrations.GoogleTrendsChangeDatesToTimestamps do
  use Ecto.Migration

  def change do
    alter table("google_trends") do
      remove :time
      add :timestamp, :integer
    end
  end
end
