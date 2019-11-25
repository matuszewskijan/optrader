defmodule Optrader.Trends do
  use Hound.Helpers
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "google_trends" do
    field :currency_name, :string
    field :currency_short_name, :string
    field :interval_number, :integer
    field :interval_unit, :string
    field :time, :naive_datetime
    field :value, :integer

    timestamps()
  end

  @doc false
  def changeset(trends, attrs) do
    trends
    |> cast(attrs, [:currency_name, :currency_short_name, :value, :interval_number, :interval_unit, :time])
    |> validate_required([:currency_name, :currency_short_name, :value, :interval_number, :interval_unit, :time])
    |> validate_unique_date
  end

  def validate_unique_date(changeset) do
    date = get_field(changeset, :time)
    if date do
      date_query = from e in Optrader.Trends, where: e.time == ^date

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

  def import_data() do
    Hound.start_session()
    maximize_window(current_window_handle())
    navigate_to "https://trends.google.com/trends"
    Process.sleep(10000)
    navigate_to "https://trends.google.com/trends/explore?date=now%207-d&q=bitcoin"
    Process.sleep(20000)
    urls = for x <- 1..50, do: execute_script("var performance = window.performance; var network = performance.getEntries() || {}; return network[#{x}]['name']")

    json = Enum.find(urls, fn url -> String.starts_with?(url, "https://trends.google.com/trends/api/widgetdata/multiline") == true end)
    |> trends_request

    { _, data } = json
    data[:default][:timelineData]
  end

  def trends_request(url) do
    url
    |> HTTPoison.get
    |> case do
        {:ok, %{body: raw, status_code: code}} -> {:ok, raw}
        {:error, %{reason: reason}} -> {:error, reason}
       end
    |> (fn {status, body} ->
          Enum.at(String.split(body, "\n"), 1)
          |> Poison.decode(keys: :atoms)
          |> case do
               {:ok, parsed} -> {status, parsed}
               _ -> {:error, body}
             end
        end).()
  end

  def save_new_trends(data, currency_info \\ default_currency) do
    new_trend = %Optrader.Trends{}

    interval_data = calculate_interval(Enum.at(data, 0)[:time], Enum.at(data, 1)[:time])

    data
    |> Enum.with_index()
    |> Enum.map(fn {data, idx} ->
      date = Optrader.Application.unix_timestamp_to_date(data[:time])

      record = %{time: date}
      |> Map.merge(interval_data)
      |> Map.merge(currency_info)
      |> Map.merge(%{value: List.first(data[:value])})

      Optrader.Trends.changeset(new_trend, record)
      |> Optrader.Repo.insert
    end)
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
end
