defmodule OptraderWeb.FearAndGreedController do
  use OptraderWeb, :controller
  require Ecto.Query
  alias Optrader.FearAndGreed

  def index(conn, _params) do
    { _, response } = FearAndGreed.import

    response[:data] |> FearAndGreed.save_new_indexes

    records = FearAndGreed |> FearAndGreed.sorted |> Optrader.Repo.all

    render(conn, "index.json", records: records)
  end

  def show(conn, %{"id" => id}) do
    record = Optrader.Repo.get(FearAndGreed, id)
    render(conn, "show.json", record: record)
  end
end
