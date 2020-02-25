defmodule OptraderWeb.TrendsController do
  use OptraderWeb, :controller
  require Ecto.Query
  alias Optrader.Trends
  alias Optrader.Synchronization

  def index(conn, params) do
    # if Synchronization.synchronization_needed?("google_trends") do
    #   imported_records_counter = google_trends_api().import_data |> Trends.save_new_trends
    #   Synchronization.create(%{service: "google_trends", imported_items: imported_records_counter})
    # end

    records = Trends
    |> Trends.in_date_range(params["startDate"], params["endDate"])
    |> Trends.with_interval(params["interval"])
    |> Trends.sort_by_timestamp
    |> Optrader.Repo.all
    |> Trends.generate_consistency_data

    render(conn, "index.json", records: records)
  end

  def show(conn, %{"id" => id}) do
    record = Optrader.Repo.get(FearAndGreed, id)
    render(conn, "show.json", record: record)
  end

  defp google_trends_api do
    Application.get_env(:optrader, :google_trends_api)
  end
end
