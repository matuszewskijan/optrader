defmodule Optrader.FearAndGreed do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @one_day 86400

  schema "f_g_index" do
    field :timestamp, :integer
    field :value, :string
    field :value_classification, :string

    timestamps()
  end

  @doc false
  def changeset(fear_and_greed, attrs) do
    fear_and_greed
    |> cast(attrs, [:value, :value_classification, :timestamp])
    |> validate_required([:value, :value_classification, :timestamp])
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

  def import(params \\ [{"limit", 10 }], headers \\ []) do
    url = "https://api.alternative.me/fng/"

    url
    |> HTTPoison.get(headers, params: params)
    |> case do
        {:ok, %{body: raw, status_code: code}} -> {:ok, raw}
        {:error, %{reason: reason}} -> {:error, reason}
       end
    |> (fn {status, body} ->
          body
          |> Poison.decode(keys: :atoms)
          |> case do
               {:ok, parsed} -> {status, parsed}
               _ -> {:error, body}
             end
        end).()
  end

  def save_new_indexes(data) do
    f_g_index = %Optrader.FearAndGreed{}

    List.wrap(data)
    |> Enum.with_index()
    |> Enum.map(fn {index, id} ->
      f_g_index
      |> Optrader.FearAndGreed.changeset(Map.merge(index, %{ timestamp: String.to_integer(index[:timestamp]) }))
      |> Optrader.Repo.insert
    end)
  end

  # TODO: Support sorting direction here
  def sort_by_timestamp(query) do
    from f in query,
    order_by: [asc: f.timestamp]
  end

  def in_date_range(query, start_date \\ nil, end_date \\ nil) do
    if start_date && end_date do
      from f in query,
      where: f.timestamp >= ^String.to_integer(start_date) and f.timestamp <= ^String.to_integer(end_date)
    else
      query
    end
  end

  # There is no other interval than 24 for Fear And Greed indexes
  def with_interval(query, interval) do
    if interval && interval != "24" do
      from f in query,
      where: f.id == 0;
    else
      query
    end
  end

  def generate_consistency_data(records) do
    records
    |> Enum.with_index()
    |> Enum.map(fn {index, i} ->
         if (next_element = Enum.at(records, i + 1)) do
           next_timestamp = next_element.timestamp
           if (time_difference = (next_timestamp - index.timestamp)) != @one_day do
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

  def generate_dummy_objects(count, last_value, next_value, last_timestamp) do
    last_value = String.to_integer(last_value)
    next_value = String.to_integer(next_value)

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
