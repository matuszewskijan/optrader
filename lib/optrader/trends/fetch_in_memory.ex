defmodule Optrader.Trends.FetchInMemory do

  @behaviour FetchTrendsBehaviour

  def import_data() do
    data =
      %{"default":
        %{"timelineData":
          [
            %{
              "time": "1581865200",
              "formattedTime": "16 lut 2020 o 16:00",
              "formattedAxisTime": "16 lut o 16:00",
              "value": [57],
              "hasData": [true],
              "formattedValue": ["57"]
            }
          ]
        }
      }

    Jason.encode!(data)
  end

end
