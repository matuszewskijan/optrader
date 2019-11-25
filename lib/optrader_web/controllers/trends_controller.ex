defmodule OptraderWeb.TrendsController do
  use OptraderWeb, :controller
  require Ecto.Query
  alias Optrader.Trends

  def index(conn, _params) do
    # Trends.import_data |> Trends.save_new_trends

    records = Trends |> Optrader.Repo.all

    render(conn, "index.json", records: records)
  end

  def show(conn, %{"id" => id}) do
    record = Optrader.Repo.get(FearAndGreed, id)
    render(conn, "show.json", record: record)
  end
end
