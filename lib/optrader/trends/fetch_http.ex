defmodule Optrader.Trends.FetchHttp do

  use Hound.Helpers
  @behaviour FetchTrendsBehaviour

  @user_service Application.get_env(:mox_guide, :user_service)

  def import_data() do
    Hound.start_session()
    maximize_window(current_window_handle())
    navigate_to "https://trends.google.com/trends"
    Process.sleep(10000)
    navigate_to "https://trends.google.com/trends/explore?date=now%207-d&q=bitcoin"
    # TODO: Get rid of this sleep
    Process.sleep(20000)
    urls = for x <- 1..50, do: execute_script("var performance = window.performance; var network = performance.getEntries() || {}; return network[#{x}]['name']")

    { _, data } = Enum.find(urls, fn url -> String.starts_with?(url, "https://trends.google.com/trends/api/widgetdata/multiline") == true end)
    |> trends_request

    data[:default][:timelineData]
  end

  defp trends_request(url) do
    url
    |> HTTPoison.get
    |> case do
        {:ok, %{body: raw, status_code: code}} -> {:ok, raw}
        {:error, %{reason: reason}} -> {:error, reason}
       end
    |> (fn {status, body} ->
          Enum.at(String.split(body, "\n"), 1)
          |> Poison.decode(keys: :atoms)
          |> case do
               {:ok, parsed} -> {status, parsed}
               _ -> {:error, body}
             end
        end).()
  end

end
