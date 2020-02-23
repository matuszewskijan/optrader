defmodule Optrader.FearAndGreed.FetchInMemory do
  def import(params \\ [{"limit", 10 }], headers \\ []) do
    data = %{
              data: [
                %{
                  value: "46",
                  value_classification: "Fear",
                  timestamp: "1582434000",
                  time_until_update: "52521"
                }
              ]
            }

    Jason.encode!(data)
  end
end
