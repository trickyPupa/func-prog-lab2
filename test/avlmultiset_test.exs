defmodule AVLMultisetTest do
  use ExUnit.Case
  use ExUnitProperties

  setup_all do
    set = AVLMultiset.new()

    set = set
    |> AVLMultiset.add(5)
    |> AVLMultiset.add(2)
    |> AVLMultiset.add(5)
    |> AVLMultiset.add(3)
    |> AVLMultiset.add(5)
    |> AVLMultiset.add(10)

    {:ok, set: set}
  end

  test "add", %{set: set} do
    assert set
  end

  test "contains", %{set: set} do
    assert AVLMultiset.contains?(set, 5)
    assert AVLMultiset.contains?(set, 10)
    assert not AVLMultiset.contains?(set, 4)
  end

  test "count", %{set: set} do
    assert 3 == AVLMultiset.count(set, 5)
    assert 1 == AVLMultiset.count(set, 3)
    assert 1 == AVLMultiset.count(set, 10)
    assert 0 == AVLMultiset.count(set, 93)
  end

  test "remove", %{set: set} do
    assert 3 == AVLMultiset.count(set, 5)
    assert 1 == AVLMultiset.count(set, 3)

    set = AVLMultiset.remove(set, 5)
    set = AVLMultiset.remove(set, 3)
    assert 2 == AVLMultiset.count(set, 5)
    assert 0 == AVLMultiset.count(set, 3)

    assert not AVLMultiset.contains?(set, 4)
    set = AVLMultiset.remove(set, 4)
    assert not AVLMultiset.contains?(set, 4)
  end

  test "to_list", %{set: set} do
    assert [2, 3, 5, 5, 5, 10] == AVLMultiset.to_list(set)

    set = AVLMultiset.remove(set, 5)
    assert [2, 3, 5, 5, 10] == AVLMultiset.to_list(set)

    set = AVLMultiset.remove(set, 3)
    set = AVLMultiset.remove(set, 5)
    set = AVLMultiset.remove(set, 2)
    assert [5, 10] == AVLMultiset.to_list(set)

    set = set |> AVLMultiset.add(1) |> AVLMultiset.add(17) |> AVLMultiset.add(19)
    assert [1, 5, 10, 17, 19] == AVLMultiset.to_list(set)
  end
end
