defmodule Optrader.Trends do
  alias Optrader.Trends

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "google_trends" do
    field :currency_name, :string
    field :currency_short_name, :string
    field :interval_number, :integer
    field :interval_unit, :string
    field :timestamp, :integer
    field :value, :integer

    timestamps()
  end

  @doc false
  def changeset(trends, attrs) do
    trends
    |> cast(attrs, [:currency_name, :currency_short_name, :value, :interval_number, :interval_unit, :timestamp])
    |> validate_required([:currency_name, :currency_short_name, :value, :interval_number, :interval_unit, :timestamp])
    |> validate_unique_timestamp
  end

  def validate_unique_timestamp(changeset) do
    timestamp = get_field(changeset, :timestamp)
    if timestamp do
      timestamp_query = from e in Optrader.FearAndGreed, where: e.timestamp == ^timestamp

      # For updates, don't flag event as a dup of itself
      id = get_field(changeset, :id)
      timestamp_query = if is_nil(id) do
        timestamp_query
      else
        from e in timestamp_query, where: e.id != ^id
      end

      dups = timestamp_query |> Optrader.Repo.all
      if Enum.any?(dups) do
        add_error(
          changeset,
          :timestamp,
          "has already been taken",
          [validation: :validate_unique_timestamp]
        )
      else
        changeset
      end
    else
      changeset
    end
  end

  def save_new_trends(data, currency_info \\ default_currency()) do
    interval_data = calculate_interval(Enum.at(data, 0)[:time], Enum.at(data, 1)[:time])

    data
    |> Enum.with_index()
    |> Enum.map(fn {data, _idx} ->
      current_time = NaiveDateTime.utc_now()|> NaiveDateTime.truncate(:second)
      timestamp = String.to_integer(data[:time])

      %{timestamp: timestamp}
      |> Map.merge(interval_data)
      |> Map.merge(currency_info)
      |> Map.merge(%{inserted_at: current_time, updated_at: current_time})
      |> Map.merge(%{value: List.first(data[:value])})
    end)
    |> Trends.create_many
  end

  def create_many(trends) do
    {created, _} = Optrader.Repo.insert_all(Trends, trends)
    created
  end

  defp calculate_interval(date_1, date_2) do
    time_difference = String.to_integer(date_2) - String.to_integer(date_1)

    if time_difference == 3600 do
      %{ interval_number: 1, interval_unit: "hour"}
    end
  end

  defp default_currency do
    %{currency_name: "bitcoin", currency_short_name: "btc"}
  end

  def sorted(query) do
    from p in query,
    order_by: [asc: p.timestamp]
  end
end
