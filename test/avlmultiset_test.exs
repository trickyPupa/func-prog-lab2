defmodule AVLMultisetTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Multiset.AVLMultiset

  setup_all do
    set = AVLMultiset.new()

    set =
      set
      |> Multiset.add(5)
      |> Multiset.add(2)
      |> Multiset.add(5)
      |> Multiset.add(3)
      |> Multiset.add(5)
      |> Multiset.add(10)

    {:ok, set: set}
  end

  test "add", %{set: set} do
    assert set
  end

  test "contains", %{set: set} do
    assert Multiset.contains?(set, 5)
    assert Multiset.contains?(set, 10)
    assert not Multiset.contains?(set, 4)
  end

  test "count", %{set: set} do
    assert 3 == Multiset.count(set, 5)
    assert 1 == Multiset.count(set, 3)
    assert 1 == Multiset.count(set, 10)
    assert 0 == Multiset.count(set, 93)
  end

  test "remove", %{set: set} do
    assert 3 == Multiset.count(set, 5)
    assert 1 == Multiset.count(set, 3)

    set = Multiset.remove(set, 5)
    set = Multiset.remove(set, 3)
    assert 2 == Multiset.count(set, 5)
    assert 0 == Multiset.count(set, 3)

    assert not Multiset.contains?(set, 4)
    set = Multiset.remove(set, 4)
    assert not Multiset.contains?(set, 4)
  end

  test "to_list", %{set: set} do
    IO.inspect(Enum.reduce(set, [], fn x, acc -> [x | acc] end))
    # assert [2, 3, 5, 5, 5, 10] == Multiset.to_list(set)

    set = Multiset.remove(set, 5)
    # assert [2, 3, 5, 5, 10] == Multiset.to_list(set)

    set = Multiset.remove(set, 3)
    set = Multiset.remove(set, 5)
    set = Multiset.remove(set, 2)
    # assert [5, 10] == Multiset.to_list(set)

    set = set |> Multiset.add(1) |> Multiset.add(17) |> Multiset.add(19)
    # assert [1, 5, 10, 17, 19] == Multiset.to_list(set)
  end
end
