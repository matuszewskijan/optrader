defmodule OptraderWeb.FearAndGreedView do
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
      date: record.date,
      value: record.value,
      value_classification: record.value_classification
    }
  end
end
