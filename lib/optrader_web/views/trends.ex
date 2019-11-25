defmodule OptraderWeb.TrendsView do
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
      currency_name: record.currency_name,
      currency_short_name: record.currency_short_name,
      datetime: record.time,
      interval_number: record.interval_number,
      interval_unit: record.interval_unit,
      value: record.value
    }
  end
end
