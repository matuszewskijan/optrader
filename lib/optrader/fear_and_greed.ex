defmodule Optrader.FearAndGreed do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

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

    data
    |> Enum.with_index()
    |> Enum.map(fn {index, id} ->
      f_g_index
      |> Optrader.FearAndGreed.changeset(Map.merge(index, %{ timestamp: String.to_integer(index[:timestamp]) }))
      |> Optrader.Repo.insert
    end)
  end

  def sorted(query) do
    from p in query,
    order_by: [asc: p.timestamp]
  end
end
