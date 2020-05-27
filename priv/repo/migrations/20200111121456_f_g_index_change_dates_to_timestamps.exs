defmodule Optrader.Repo.Migrations.FGIndexChangeDatesToTimestamps do
  use Ecto.Migration

  def change do
    alter table("f_g_index") do
      remove :date
      add :timestamp, :integer
    end
  end
end
