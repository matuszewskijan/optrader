defmodule OptraderWeb.FearAndGreedView do
  import Timex
  use OptraderWeb, :view

  def render("index.json", %{records: records}) do
    %{
      data: Enum.map(records, &records_json/1)
    }
  end

  def render("show.json", %{record: record}) do
    %{data: records_json(record)}
  end

  def records_json(record) do
    %{
      id: record.id,
      value: record.value,
      label: record.value_classification,
      datetime: DateTime.from_unix!(record.timestamp, :second) |> Timex.format!("{ISOdate} {ISOtime}"),
      date: DateTime.from_unix!(record.timestamp, :second) |> Timex.format!("{YYYY}/{M}/{D}"),
      timestamp: record.timestamp
    }
  end
end
