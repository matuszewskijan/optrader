defmodule Optrader.TrendsTest do
  use Optrader.DataCase

  describe "Google Trends" do
    alias Optrader.Trends

    @one_day 86400

    # Keep in mind that attrs are in format which we are receiving from Google Trends API
    @valid_attrs1 %{value: [100], currency_name: "bitcoin", currency_short_name: "btc", interval_number: 1, interval_unit: "day", time: "#{@one_day}"}
    @valid_attrs2 %{value: [0], currency_name: "bitcoin", currency_short_name: "btc", interval_number: 1, interval_unit: "day", time: "#{@one_day * 2}"}
    @invalid_attrs %{value: [], time: "1573577402"}

    test "trend with duplicated timestamp is invalid" do
      Trends.save_new_trends([@valid_attrs1])

      new_trend = Trends.changeset(%Trends{}, @valid_attrs1)

      assert new_trend.valid? == false
    end

    test "save_new_trends/2 with valid data create new indexes" do
      %{ success: success, failed: invalid } = Trends.save_new_trends([@valid_attrs1, @valid_attrs2])

      assert success == 2
      assert invalid == 0
      assert Optrader.Repo.get_by(Trends, value: "100") != nil
      assert Optrader.Repo.get_by(Trends, value: "0") != nil
    end

    test "save_new_trends/2 with invalid data return number of invalid entities" do
      %{ success: success, failed: invalid } = Trends.save_new_trends([@valid_attrs1, @invalid_attrs])

      assert success == 1
      assert invalid == 1
    end

    test "save_new_trends/2 without data return zero success and fails" do
      %{ success: success, failed: invalid } = Trends.save_new_trends([])

      assert success == 0
      assert invalid == 0
    end

    test "sort_by_timestamp/1 sorts data by timestamp" do
      Trends.save_new_trends([@valid_attrs1, @valid_attrs2, Map.merge(@valid_attrs2, %{ time: "0" })])

      records = Trends
      |> Trends.sort_by_timestamp
      |> Optrader.Repo.all

      assert Enum.at(records, 0).timestamp < Enum.at(records, 1).timestamp
      assert Enum.at(records, 1).timestamp < Enum.at(records, 2).timestamp
    end

    test "in_date_range/3 does nothing without start and end date" do
      Trends.save_new_trends([@valid_attrs1, @valid_attrs2, Map.merge(@valid_attrs2, %{ time: "0" })])

      records_count = Trends
      |> Trends.in_date_range
      |> Optrader.Repo.all
      |> Enum.count

      assert records_count == 3
    end

    test "in_date_range/3 filters resource in given date range" do
      Trends.save_new_trends([@valid_attrs1, @valid_attrs2, Map.merge(@valid_attrs2, %{ time: "0" })])

      records_count = Trends
      |> Trends.in_date_range("0", "#{@one_day}")
      |> Optrader.Repo.all
      |> Enum.count

      assert records_count == 2
    end

    test "generate_consistency_data/1 returns unchanged data when no time gaps inside" do
      Trends.save_new_trends([@valid_attrs1, @valid_attrs2, Map.merge(@valid_attrs2, %{ time: "0" })])

      records = Trends
      |> Trends.sort_by_timestamp
      |> Optrader.Repo.all

      consistent_records = Trends.generate_consistency_data(records)
      assert records == consistent_records
    end

    test "generate_consistency_data/1 returns virtual objects with average data when time gap inside" do
      records = [
        Map.merge(@valid_attrs1, %{ time: "0" }),
        Map.merge(@valid_attrs2, %{ time: "#{@one_day * 3}"})
      ]

      Trends.save_new_trends(records)

      records = Trends
      |> Trends.sort_by_timestamp
      |> Optrader.Repo.all

      consistent_records = Trends.generate_consistency_data(records)

      assert Enum.count(consistent_records) == 4
      assert Enum.at(consistent_records, 0).timestamp == @one_day * 0
      assert Enum.at(consistent_records, 1).timestamp == @one_day * 1
      assert Enum.at(consistent_records, 2).timestamp == @one_day * 2
      assert Enum.at(consistent_records, 3).timestamp == @one_day * 3

      assert Enum.at(consistent_records, 1).label == 'Average from latest available values'
      assert consistent_records != records
    end

    test "generate_dummy_objects/4 generates dumy objects with correct values" do
      count = 2
      last_value = 100
      next_value = 0
      last_timestamp = 0
      objects = Trends.generate_dummy_objects(count, last_value, next_value, last_timestamp)

      assert Enum.count(objects) == 2
      assert Enum.at(objects, 0).timestamp == last_timestamp + @one_day
      assert Enum.at(objects, 1).timestamp == last_timestamp + (@one_day * 2)
    end
  end
end
