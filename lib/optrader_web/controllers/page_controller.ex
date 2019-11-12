defmodule OptraderWeb.PageController do
  use OptraderWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
