defmodule Optrader.FearAndGreed do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "f_g_index" do
    field :date, :naive_datetime
    field :value, :string
    field :value_classification, :string

    timestamps()
  end

  @doc false
  def changeset(fear_and_greed, attrs) do
    fear_and_greed
    |> cast(attrs, [:value, :value_classification, :date])
    |> validate_required([:value, :value_classification, :date])
    |> validate_unique_date
  end

  # TODO: Check if index from this date already exists
  def validate_unique_date(changeset) do
    date = get_field(changeset, :date)
    if date do
      date_query = from e in Optrader.FearAndGreed, where: e.date == ^date

      # For updates, don't flag event as a dup of itself
      id = get_field(changeset, :id)
      date_query = if is_nil(id) do
        date_query
      else
        from e in date_query, where: e.id != ^id
      end

      dups = date_query |> Optrader.Repo.all
      if Enum.any?(dups) do
        add_error(
          changeset,
          :date,
          "has already been taken",
          [validation: :validate_unique_name]
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
    |> Enum.map(fn {e, idx} ->
      date = Optrader.Application.unix_timestamp_to_date(e[:timestamp])

      e = Map.put(e, :date, date)

      index = Optrader.FearAndGreed.changeset(f_g_index, e)

      Optrader.Repo.insert(index)
    end)
  end

  def sorted(query) do
    from p in query,
    order_by: [desc: p.date]
  end
end
