defmodule Optrader.Synchronization do
  alias Optrader.Synchronization

  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.Query

  schema "synchronizations" do
    field :imported_items, :integer
    field :service, :string

    timestamps()
  end

  @doc false
  def changeset(synchronization, attrs) do
    synchronization
    |> cast(attrs, [:service, :imported_items])
    |> validate_required([:service, :imported_items])
  end

  def synchronize_google_trends do
    last_sync = find_latest_google_trends_sync

    if last_sync == nil || NaiveDateTime.diff(NaiveDateTime.utc_now, last_sync.inserted_at) > 3600 do
      { count, _ } = Optrader.Trends.import_data |> Optrader.Trends.save_new_trends

      Optrader.Synchronization.changeset(%Optrader.Synchronization{}, %{service: "google_trends", imported_items: count})
      |> Optrader.Repo.insert
    end
  end

  def synchronize_fear_and_greed do
    last_sync = find_latest_fear_and_greed_sync

    if last_sync == nil || NaiveDateTime.diff(NaiveDateTime.utc_now, last_sync.inserted_at) > 3600 do
      poll_size = if last_sync == nil do
                    10000
                  else
                    NaiveDateTime.diff(NaiveDateTime.utc_now, last_sync.inserted_at) / (3600 * 24)
                  end

      { _, response } = Optrader.FearAndGreed.import([{"limit", poll_size}])

      { count, _ } = response[:data] |> Optrader.FearAndGreed.save_new_indexes
      require IEx; IEx.pry;
      Optrader.Synchronization.changeset(%Optrader.Synchronization{}, %{service: "fear_and_greed", imported_items: count})
      |> Optrader.Repo.insert
    end
  end


  def find_latest_google_trends_sync do
    (Ecto.Query.from s in Synchronization,
    where: s.service == "google_trends",
    order_by: [desc: :inserted_at], limit: 1)
    |> Optrader.Repo.one
  end

  def find_latest_fear_and_greed_sync do
    (Ecto.Query.from s in Synchronization,
    where: s.service == "fear_and_greed",
    order_by: [desc: :inserted_at], limit: 1)
    |> Optrader.Repo.one
  end
end
