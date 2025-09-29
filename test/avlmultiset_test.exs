defmodule AVLMultisetUnitTest do
  use ExUnit.Case

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
      |> Multiset.add(15)
      |> Multiset.add(121)

    {:ok, set: set}
  end

  test "add", %{set: set} do
    assert set
  end

  test "contains + empty", %{set: set} do
    assert Multiset.contains?(set, 5)
    assert Multiset.contains?(set, 10)
    assert not Multiset.contains?(set, 4)

    assert not Multiset.empty?(set)

    set = AVLMultiset.new()
    assert Multiset.empty?(set)
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

    set = set |> Multiset.add(1) |> Multiset.add(17) |> Multiset.add(19) |> Multiset.add(899)

    assert not Multiset.contains?(set, 4)
    set = Multiset.remove(set, 4)
    assert not Multiset.contains?(set, 4)
  end

  test "size", %{set: set} do
    assert 8 == Multiset.size(set)

    set = set
    |> Multiset.remove(5)
    |> Multiset.remove(5)
    |> Multiset.remove(3)

    assert 5 == Multiset.size(set)

    set = set
    |> Multiset.remove(5)
    |> Multiset.remove(10)
    |> Multiset.remove(15)
    |> Multiset.add(1)

    assert 3 == Multiset.size(set)
  end

  test "to_list (foldr)", %{set: set} do
    assert [2, 3, 5, 5, 5, 10, 15, 121] == AVLMultiset.to_list(set)

    set = Multiset.remove(set, 5)
    set = Multiset.remove(set, 5)
    assert [2, 3, 5, 10, 15, 121] == AVLMultiset.to_list(set)

    set = Multiset.remove(set, 3)
    set = Multiset.remove(set, 5)
    set = Multiset.remove(set, 2)
    assert [10, 15, 121] == AVLMultiset.to_list(set)

    set = set |> Multiset.add(1) |> Multiset.add(17) |> Multiset.add(19)
    assert [1, 10, 15, 17, 19, 121] == AVLMultiset.to_list(set)
  end

  test "filter", %{set: set} do
    assert Multiset.contains?(set, 5)
    assert Multiset.contains?(set, 2)
    assert Multiset.contains?(set, 15)

    set = set
    |> Multiset.filter(fn x -> x > 10 end)

    assert not Multiset.contains?(set, 5)
    assert not Multiset.contains?(set, 2)
    assert Multiset.contains?(set, 15)
    assert Multiset.contains?(set, 121)

    set = set
    |> Multiset.filter(fn x -> x < 100 end)

    assert not Multiset.contains?(set, 121)

    assert [15] == AVLMultiset.to_list(set)
  end

  test "foldr", %{set: set} do
    result = AVLMultiset.foldr(set, [], fn x, acc -> [x | acc] end)
    assert result == [2, 3, 5, 5, 5, 10, 15, 121]

    sum = AVLMultiset.foldr(set, 0, fn x, acc -> x + acc end)
    assert sum == 166
  end

  test "foldl", %{set: set} do
    result = AVLMultiset.foldl(set, [], fn x, acc -> [x | acc] end)
    assert result == [121, 15, 10, 5, 5, 5, 3, 2]

    sum = AVLMultiset.foldl(set, 0, fn acc, x -> acc + x end)
    assert sum == 166
  end

  test "map", %{set: set} do
    mapped = Multiset.map(set, fn x -> x * 2 end)
    assert AVLMultiset.to_list(mapped) == [4, 6, 10, 10, 10, 20, 30, 242]

    mapped2 = Multiset.map(set, fn _ -> 1 end)
    assert AVLMultiset.to_list(mapped2) == [1, 1, 1, 1, 1, 1, 1, 1]
  end
end
