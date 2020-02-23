defmodule OptraderWeb.TrendsController do
  use OptraderWeb, :controller
  require Ecto.Query
  alias Optrader.Trends
  alias Optrader.Synchronization

  def index(conn, _params) do
    if Synchronization.synchronization_needed?("google_trends") do
      imported_records_counter = google_trends_api().import_data |> Trends.save_new_trends
      Synchronization.create(%{service: "google_trends", imported_items: imported_records_counter})
    end

    records = Trends |> Trends.sorted |> Optrader.Repo.all

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
