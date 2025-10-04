defmodule Multiset.MultisetPropertyTest do
  use ExUnit.Case
  use PropCheck

  alias Multiset.AVLMultiset

  defp avl_balanced?(nil), do: true

  defp avl_balanced?(%AVLMultiset.Node{left: left, right: right, height: height}) do
    left_height = height(left)
    right_height = height(right)

    abs(left_height - right_height) <= 1 and
      height == 1 + max(left_height, right_height) and
      avl_balanced?(left) and avl_balanced?(right)
  end

  defp height(nil), do: 0
  defp height(%AVLMultiset.Node{height: h}), do: h

  defp multiset do
    let elements <- list(integer()) do
      Enum.reduce(elements, AVLMultiset.new(), fn x, acc -> Multiset.add(acc, x) end)
    end
  end

  defp non_empty_multiset do
    let elements <- non_empty(list(integer())) do
      Enum.reduce(elements, AVLMultiset.new(), fn x, acc -> Multiset.add(acc, x) end)
    end
  end

  property "adding increases size and count" do
    forall {ms, key} <- {multiset(), integer()} do
      initial_size = Multiset.size(ms)
      initial_count = Multiset.count(ms, key)
      new_ms = Multiset.add(ms, key)

      assert Multiset.size(new_ms) == initial_size + 1
      assert Multiset.count(new_ms, key) == initial_count + 1
      assert Multiset.contains?(new_ms, key)
    end
  end

  property "removing decreases size and count" do
    forall {ms, key} <- {non_empty_multiset(), integer()} do
      initial_size = Multiset.size(ms)
      initial_count = Multiset.count(ms, key)
      new_ms = Multiset.remove(ms, key)

      if initial_count > 0 do
        assert Multiset.size(new_ms) == initial_size - 1
        assert Multiset.count(new_ms, key) == initial_count - 1
      else
        assert Multiset.size(new_ms) == initial_size
        assert Multiset.count(new_ms, key) == 0
      end
    end
  end

  property "filter correctly" do
    forall ms <- multiset() do
      predicate = fn x -> rem(x, 2) == 0 end
      filtered_ms = Multiset.filter(ms, predicate)

      AVLMultiset.to_list(filtered_ms)
      |> Enum.all?(fn x -> predicate.(x) end)
    end
  end

  property "map correctly" do
    forall ms <- multiset() do
      fun = fn x -> x * 2 end
      mapped_ms = Multiset.map(ms, fun)
      original_list = AVLMultiset.to_list(ms)
      mapped_list = AVLMultiset.to_list(mapped_ms)

      assert Enum.sort(mapped_list) == Enum.sort(Enum.map(original_list, fun))
    end
  end

  property "foldl and foldr produce consistent results" do
    forall ms <- multiset() do
      fun = fn x, acc -> acc + x end
      initial_acc = 0

      foldl_result = Multiset.foldl(ms, initial_acc, fun)
      foldr_result = Multiset.foldr(ms, initial_acc, fun)

      assert foldl_result == foldr_result
    end
  end

  property "to_list preserves all elements with correct counts" do
    forall ms <- multiset() do
      list = AVLMultiset.to_list(ms)
      counts = Enum.frequencies(list)

      Enum.all?(counts, fn {key, count} ->
        Multiset.count(ms, key) == count
      end)
    end
  end

  property "adding and removing maintains AVL balance" do
    forall ops <- list({oneof([:add, :remove]), integer()}) do
      ms =
        Enum.reduce(ops, AVLMultiset.new(), fn
          {:add, key}, acc -> Multiset.add(acc, key)
          {:remove, key}, acc -> Multiset.remove(acc, key)
        end)

      assert avl_balanced?(ms.root)
    end
  end

    property "union left identity: union(return(x), m) behaves correctly" do
    forall {x, m} <- {integer(), multiset()} do
      return_x = Multiset.add(AVLMultiset.new(), x)
      union_result = Multiset.union(return_x, m)

      assert Multiset.count(union_result, x) == 1 + Multiset.count(m, x)
      m_list = AVLMultiset.to_list(m)
      assert Enum.all?(m_list, fn e ->
        e == x || Multiset.count(union_result, e) == Multiset.count(m, e)
      end)
    end
  end

  property "union right identity: union(m, return(x)) behaves correctly" do
    forall {m, x} <- {multiset(), integer()} do
      return_x = Multiset.add(AVLMultiset.new(), x)
      union_result = Multiset.union(m, return_x)

      assert Multiset.count(union_result, x) == Multiset.count(m, x) + 1
      m_list = AVLMultiset.to_list(m)
      assert Enum.all?(m_list, fn e ->
        e == x || Multiset.count(union_result, e) == Multiset.count(m, e)
      end)
    end
  end

  property "union associativity: union(union(m1, m2), m3) == union(m1, union(m2, m3))" do
    forall {m1, m2, m3} <- {multiset(), multiset(), multiset()} do
      left = Multiset.union(Multiset.union(m1, m2), m3)
      right = Multiset.union(m1, Multiset.union(m2, m3))

      left_list = AVLMultiset.to_list(left)
      right_list = AVLMultiset.to_list(right)

      assert left_list == right_list
    end
  end

  property "unioin with neutral element" do
    forall ms <- multiset() do
      empty_ms = AVLMultiset.new()

      list = AVLMultiset.to_list(ms)

      assert Multiset.union(ms, empty_ms) |> AVLMultiset.to_list == list
      assert Multiset.union(empty_ms, ms) |> AVLMultiset.to_list == list
    end
  end

  property "union maintains AVL balance" do
    forall {m1, m2} <- {multiset(), multiset()} do
      union_result = Multiset.union(m1, m2)
      assert avl_balanced?(union_result.root)
    end
  end
end
