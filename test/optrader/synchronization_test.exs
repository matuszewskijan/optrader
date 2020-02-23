defmodule Optrader.SynchronizeTest do
  use Optrader.DataCase

  describe "Data Synchronization" do
    alias Optrader.Synchronization

    import Mox
    # setup :verify_on_exit!

    @valid_attrs %{service: "google_trends", imported_items: 1}
    @valid_attrs2 %{service: "google_trends", imported_items: 3}

    test "synchronization_needed?/1 is true for first synchronization" do
      assert Synchronization.synchronization_needed?("google_trends") == true
    end

    test "synchronization_needed?/1 is true when last sync was more than hour ago" do
      date_hour_ago = NaiveDateTime.utc_now() |> NaiveDateTime.add(-3601) |> NaiveDateTime.truncate(:second)

      record = [Map.merge(@valid_attrs, %{inserted_at: date_hour_ago, updated_at: date_hour_ago})]
      Optrader.Repo.insert_all(Synchronization, record)

      assert Synchronization.synchronization_needed?("google_trends") == true
    end

    test "synchronization_needed?/1 is false when last sync was less than hour ago" do
      date_10_minutes_ago = NaiveDateTime.utc_now() |> NaiveDateTime.add(-600) |> NaiveDateTime.truncate(:second)

      record = [Map.merge(@valid_attrs, %{inserted_at: date_10_minutes_ago, updated_at: date_10_minutes_ago})]
      Optrader.Repo.insert_all(Synchronization, record)

      assert Synchronization.synchronization_needed?("google_trends") == false
    end

    test "days_since_last_sync/1 is 100000 for first sync" do
      assert Synchronization.days_since_last_sync("google_trends") == 100_000
    end

    test "days_since_last_sync/1 calculate days since last sync" do
      date_7_days_ago = NaiveDateTime.utc_now() |> NaiveDateTime.add((-3600*24)*7) |> NaiveDateTime.truncate(:second)

      record = [Map.merge(@valid_attrs, %{inserted_at: date_7_days_ago, updated_at: date_7_days_ago})]
      Optrader.Repo.insert_all(Synchronization, record)

      assert Synchronization.days_since_last_sync("google_trends") == 7
    end

    test "latest_sync/1 return nothing" do
      assert Synchronization.latest_sync("google_trends") == nil
    end

    test "latest_sync/1 return latest sync info" do
      record1 = Synchronization.create(@valid_attrs)
      Process.sleep(1000)
      record_2 = Synchronization.create(@valid_attrs2)
      assert Synchronization.latest_sync("google_trends").imported_items == 3
    end

    test "create/1 create new sync record" do
      assert {:ok, data} = Synchronization.create(@valid_attrs)
    end

  end
end
