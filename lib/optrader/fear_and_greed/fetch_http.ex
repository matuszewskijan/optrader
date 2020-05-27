defmodule Optrader.FearAndGreed.FetchHttp do
  def import(params \\ [{"limit", 10 }], headers \\ []) do
    url = "https://api.alternative.me/fng/"

    { :ok, result } = url
    |> HTTPoison.get(headers, params: params)
    |> case do
        {:ok, %{body: raw, status_code: code}} -> {:ok, raw}
        {:error, %{reason: reason}} -> {:error, reason}
       end
    |> (fn {status, body} ->
          body
          |> Poison.decode(keys: :atoms)
          |> case do
               {:ok, parsed} -> {status, parsed}
               _ -> {:error, body} # TODO: Don't swallow errors here?
             end
        end).()

    result
  end
end
