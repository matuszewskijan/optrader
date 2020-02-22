defmodule OptraderWeb.TrendsController do
  use OptraderWeb, :controller
  require Ecto.Query
  alias Optrader.Trends

  def index(conn, _params) do
    Optrader.Synchronization.synchronize_google_trends

    records = Trends |> Trends.sorted |> Optrader.Repo.all

    render(conn, "index.json", records: records)
  end

  def show(conn, %{"id" => id}) do
    record = Optrader.Repo.get(FearAndGreed, id)
    render(conn, "show.json", record: record)
  end
end
