defmodule OptraderWeb.FearAndGreedController do
  use OptraderWeb, :controller
  require Ecto.Query
  alias Optrader.FearAndGreed
  alias Optrader.Synchronization

  def index(conn, params) do
    if Synchronization.synchronization_needed?("google_trends") do
      imported_records_counter =
      fear_and_greed_api().import([{"limit", Synchronization.days_since_last_sync("google_trends")}]).data
      |> FearAndGreed.save_new_indexes

      Synchronization.create(%{service: "fear_and_greed", imported_items: imported_records_counter[:success]})
    end

    records = FearAndGreed
    |> FearAndGreed.in_date_range(params["startDate"], params["endDate"])
    |> FearAndGreed.with_interval(params["interval"])
    |> FearAndGreed.sort_by_timestamp
    |> Optrader.Repo.all
    |> FearAndGreed.generate_consistency_data

    render(conn, "index.json", records: records)
  end

  def show(conn, %{"id" => id}) do
    record = Optrader.Repo.get(FearAndGreed, id)
    render(conn, "show.json", record: record)
  end

  defp fear_and_greed_api do
    Application.get_env(:optrader, :fear_and_greed_api)
  end
end
