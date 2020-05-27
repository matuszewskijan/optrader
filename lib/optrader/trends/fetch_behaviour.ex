defmodule Optrader.Trends.FetchBehaviour do
 @doc """
 Fetches data from Google Trends
 """
 @callback import_data() :: String.t()
end
