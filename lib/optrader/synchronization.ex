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

  def synchronization_needed?(service) do
    latest_sync = latest_sync(service)
    latest_sync == nil || NaiveDateTime.diff(NaiveDateTime.utc_now, latest_sync.inserted_at) > 3600
  end

  def days_since_last_sync(service) do
    latest_sync = latest_sync(service)

    days = if latest_sync == nil do
             100000 # Some large value is needed for initial sync
           else
             Kernel.ceil(NaiveDateTime.diff(NaiveDateTime.utc_now, latest_sync.inserted_at) / (3600 * 24))
           end
  end

  def latest_sync(service) do
    (Ecto.Query.from s in Synchronization,
    where: s.service == ^service,
    order_by: [desc: :inserted_at], limit: 1)
    |> Optrader.Repo.one
  end

  def create(data) do
    Optrader.Synchronization.changeset(%Optrader.Synchronization{}, data)
    |> Optrader.Repo.insert
  end
end
