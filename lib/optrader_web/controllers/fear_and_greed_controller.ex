defmodule OptraderWeb.FearAndGreedController do
  use OptraderWeb, :controller
  require Ecto.Query
  alias Optrader.FearAndGreed

  def index(conn, params) do
    # { _, response } = FearAndGreed.import

    # response[:data] |> FearAndGreed.save_new_indexes

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
end
