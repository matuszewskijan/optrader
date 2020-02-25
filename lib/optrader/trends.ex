defmodule Optrader.Trends do
  alias Optrader.Trends

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @one_day 86400

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

  # TODO: Refactor it to few small functions
  def save_new_trends(data, currency_info \\ default_currency()) do
    interval_data = Trends.calculate_interval(Enum.at(data, 0)[:time], Enum.at(data, 1)[:time])

    data
    |> Enum.with_index()
    |> Enum.map(fn {data, _idx} ->
      timestamp = String.to_integer(data[:time])

      trend = %{timestamp: timestamp}
      |> Map.merge(interval_data)
      |> Map.merge(currency_info)
      |> Map.merge(%{value: List.first(data[:value])})

      Trends.changeset(%Trends{}, trend)
      |> Optrader.Repo.insert
    end)
    |> Trends.count_created_records
  end

  def count_created_records(data) do
    Enum.reduce(data, %{success: 0, failed: 0}, fn({status, _}, x) ->
      case status do
      :ok ->
        Map.merge(x, %{ success: x.success + 1})
      :error ->
        Map.merge(x, %{ failed: x.failed + 1})
      end
    end)
  end

  def calculate_interval(date_1, date_2) do
    if is_nil(date_1) || is_nil(date_2) do
      %{ interval_number: 1, interval_unit: "hour"} # Consider 1 hour as default interval
    else
      time_difference = String.to_integer(date_2) - String.to_integer(date_1)

      %{ interval_number: Integer.floor_div(time_difference, 3600), interval_unit: "hour"}
    end
  end

  defp default_currency do
    %{currency_name: "bitcoin", currency_short_name: "btc"}
  end

  def sort_by_timestamp(query) do
    from p in query,
    order_by: [asc: p.timestamp]
  end

  def in_date_range(query, start_date \\ nil, end_date \\ nil) do
    if start_date && end_date do
      from f in query,
      where: f.timestamp >= ^String.to_integer(start_date) and f.timestamp <= ^String.to_integer(end_date)
    else
      query
    end
  end

  # TODO: Move it to the consistency or something like that module(find better name)
  def generate_consistency_data(records) do
    records
    |> Enum.with_index()
    |> Enum.map(fn {index, i} ->
         if (next_element = Enum.at(records, i + 1)) do
           next_timestamp = next_element.timestamp
           if (time_difference = (next_timestamp - index.timestamp)) != @one_day && time_difference != 0 do
             number_of_elements = Kernel.ceil(time_difference / @one_day) - 1
             generated_objects = generate_dummy_objects(number_of_elements, index.value, next_element.value, index.timestamp)
             [index, generated_objects]
           else
             index
           end
         else
           index
         end
       end)
    |> List.flatten
  end

  # TODO: Move it to the consistency or something like that module(find better name)
  def generate_dummy_objects(count, last_value, next_value, last_timestamp) do
    step = (next_value - last_value) / (count + 1)
    Enum.map(1..count, fn i ->
      %{
        id: i,
        value: last_value + (step * i),
        label: 'Average from latest available values',
        value_classification: 'None',
        timestamp: last_timestamp + (@one_day * i)
      }
    end)
  end
end
