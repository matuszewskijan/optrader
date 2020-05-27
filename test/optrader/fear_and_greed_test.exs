defmodule Optrader.FearAndGreedTest do
  use Optrader.DataCase

  describe "Fear And Greed Index" do
    alias Optrader.FearAndGreed

    @one_day 86400
    @valid_attrs1 %{value: "100", value_classification: "greed", timestamp: "#{@one_day}"}
    @valid_attrs2 %{value: "0", value_classification: "fear", timestamp: "#{@one_day * 2}"}
    @invalid_attrs %{value: nil, value_classification: "superb", timestamp: "1573577402"}

    test "index with duplicated timestamp is invalid" do
      FearAndGreed.save_new_indexes([@valid_attrs1])
      new_index = FearAndGreed.changeset(%FearAndGreed{}, @valid_attrs1)

      assert new_index.valid? == false
      assert new_index.errors == [timestamp: {"has already been taken", [validation: :validate_unique_timestamp]}]
    end

    test "save_new_indexes/1 with valid data create new indexes" do
      %{ success: success, failed: invalid } = FearAndGreed.save_new_indexes([@valid_attrs1, @valid_attrs2])

      assert success == 2
      assert invalid == 0
      assert Optrader.Repo.get_by(FearAndGreed, value: "100") != nil
      assert Optrader.Repo.get_by(FearAndGreed, value: "0") != nil
    end

    test "save_new_indexes/1 with invalid data return number of invalid entities" do
      %{ success: success, failed: invalid } = FearAndGreed.save_new_indexes([@valid_attrs1, @valid_attrs1])

      assert success == 1
      assert invalid == 1
    end

    test "save_new_indexes/1 without data return zero success and fails" do
      %{ success: success, failed: invalid } = FearAndGreed.save_new_indexes([])

      assert success == 0
      assert invalid == 0
    end

    test "sort_by_timestamp/1 sorts data by timestamp" do
      FearAndGreed.save_new_indexes([@valid_attrs1, @valid_attrs2, Map.merge(@valid_attrs2, %{ timestamp: "0" })])

      records = FearAndGreed
      |> FearAndGreed.sort_by_timestamp
      |> Optrader.Repo.all

      assert Enum.at(records, 0).timestamp < Enum.at(records, 1).timestamp
      assert Enum.at(records, 1).timestamp < Enum.at(records, 2).timestamp
    end

    test "in_date_range/3 does nothing without start and end date" do
      FearAndGreed.save_new_indexes([@valid_attrs1, @valid_attrs2, Map.merge(@valid_attrs2, %{ timestamp: "0" })])

      records_count = FearAndGreed
      |> FearAndGreed.in_date_range
      |> Optrader.Repo.all
      |> Enum.count

      assert records_count == 3
    end

    test "in_date_range/3 filters resource in given date range" do
      FearAndGreed.save_new_indexes([@valid_attrs1, @valid_attrs2, Map.merge(@valid_attrs2, %{ timestamp: "0" })])

      records_count = FearAndGreed
      |> FearAndGreed.in_date_range("0", "#{@one_day}")
      |> Optrader.Repo.all
      |> Enum.count

      assert records_count == 2
    end

    test "generate_consistency_data/1 returns unchanged data when no time gaps inside" do
      FearAndGreed.save_new_indexes([@valid_attrs1, @valid_attrs2, Map.merge(@valid_attrs2, %{ timestamp: "0" })])

      records = FearAndGreed
      |> FearAndGreed.sort_by_timestamp
      |> Optrader.Repo.all

      consistent_records = FearAndGreed.generate_consistency_data(records)
      assert records == consistent_records
    end

    test "generate_consistency_data/1 returns virtual objects with average data when time gap inside" do
      records = [
        Map.merge(@valid_attrs1, %{ timestamp: "0" }),
        Map.merge(@valid_attrs2, %{ timestamp: "#{@one_day * 3}"})
      ]
      FearAndGreed.save_new_indexes(records)

      records = FearAndGreed
      |> FearAndGreed.sort_by_timestamp
      |> Optrader.Repo.all

      consistent_records = FearAndGreed.generate_consistency_data(records)

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
      last_value = "100"
      next_value = "0"
      last_timestamp = 0
      objects = FearAndGreed.generate_dummy_objects(count, last_value, next_value, last_timestamp)

      assert Enum.count(objects) == 2
      assert Enum.at(objects, 0).timestamp == last_timestamp + @one_day
      assert Enum.at(objects, 1).timestamp == last_timestamp + (@one_day * 2)
    end
  end
end
