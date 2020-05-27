defmodule Optrader.FearAndGreed.FetchBehaviour do
 @doc """
 Fetches data from Google Trends
 """
 @callback import() :: String.t()
end
