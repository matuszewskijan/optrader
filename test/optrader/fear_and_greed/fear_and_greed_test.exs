defmodule Optrader.FearAndGreedTest do
  use Optrader.DataCase

  alias Optrader.FearAndGreed

  describe "Fear And Greed Index" do
    alias Optrader.FearAndGreed

    @valid_attrs %{value: "100", value_classification: "superb", timestamp: "1573577402"}
    # @update_attrs %{bio: "some updated bio", email: "some updated email", name: "some updated name", number_of_pets: 43}
    # @invalid_attrs %{bio: nil, email: nil, name: nil, number_of_pets: nil}


    # TODO: Add some validation tests

    test "save_new_indexes/1 with valid data creates a new index" do
      [ok: fear_and_greed] =  FearAndGreed.save_new_indexes([@valid_attrs])

      assert fear_and_greed.value == "100"
      assert fear_and_greed.value_classification == "superb"
      assert fear_and_greed.date == ~N[2019-11-12 16:50:02]
    end

    # test "create_user/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    # end

  end
end
