alias Multiset.AVLMultiset

defmodule Multiset.AVLMultiset do
  defmodule Node do
    defstruct value: nil, count: 1, height: 1, left: nil, right: nil
  end

  defstruct root: nil, size: 0

  def new, do: %AVLMultiset{}

  def contains?(bag, key), do: count(bag, key) > 0

  def count(%AVLMultiset{root: root}, key), do: do_count(root, key)

  def add(%AVLMultiset{root: root, size: size} = bag, key) do
    {new_root, delta} = insert(root, key)
    %AVLMultiset{bag | root: new_root, size: size + delta}
  end

  def size(%AVLMultiset{size: s}), do: s

  def remove(%AVLMultiset{root: root, size: size} = bag, key) do
    {new_root, delta} = delete(root, key)
    %AVLMultiset{bag | root: new_root, size: size + delta}
  end

  def empty?(%AVLMultiset{root: nil}), do: true
  def empty?(_), do: false

  def union(%AVLMultiset{} = bag1, %AVLMultiset{} = bag2) do
    AVLMultiset.foldl(bag2, bag1, fn x, acc -> AVLMultiset.add(acc, x) end)
  end

  # ===== private =====

  defp do_count(nil, _), do: 0

  defp do_count(%Node{value: v, count: c, left: l, right: r}, key) do
    cond do
      key < v -> do_count(l, key)
      key > v -> do_count(r, key)
      true -> c
    end
  end

  defp insert(nil, key), do: {%Node{value: key}, 1}

  defp insert(%Node{value: v, count: c, left: l, right: r} = node, key) do
    cond do
      key < v ->
        {new_l, delta} = insert(l, key)
        node = balance(%Node{node | left: new_l})
        {node, delta}

      key > v ->
        {new_r, delta} = insert(r, key)
        node = balance(%Node{node | right: new_r})
        {node, delta}

      true ->
        {%Node{node | count: c + 1}, 1}
    end
  end

  defp delete(nil, _), do: {nil, 0}

  defp delete(%Node{value: v, count: c, height: h, left: l, right: r} = node, key) do
    cond do
      key < v ->
        {new_l, delta} = delete(l, key)
        {balance(%Node{node | left: new_l}), delta}

      key > v ->
        {new_r, delta} = delete(r, key)
        {balance(%Node{node | right: new_r}), delta}

      c > 1 ->
        {%Node{node | count: c - 1}, -1}

      l == nil ->
        {r, -1}

      r == nil ->
        {l, -1}

      true ->
        {succ, r2} = remove_min(r)

        {balance(%Node{value: elem(succ, 0), count: elem(succ, 1), height: h, left: l, right: r2}),
         -1}
    end
  end

  defp remove_min(%Node{value: v, count: c, left: nil, right: r}), do: {{v, c}, r}

  defp remove_min(%Node{left: l} = node) do
    {min, l2} = remove_min(l)
    {min, balance(%Node{node | left: l2})}
  end

  defp balance(%Node{left: l, right: r} = node) do
    hl = height(l)
    hr = height(r)
    h = 1 + max(hl, hr)

    case hl - hr do
      d when d > 1 and not is_nil(l) ->
        if height(l.left) >= height(l.right),
          do: rotate_right(%Node{node | height: h}),
          else: rotate_right(%Node{node | height: h, left: rotate_left(l)})

      d when d < -1 and not is_nil(r) ->
        if height(r.right) >= height(r.left),
          do: rotate_left(%Node{node | height: h}),
          else: rotate_left(%Node{node | height: h, right: rotate_right(r)})

      _ ->
        %Node{node | height: h}
    end
  end

  defp height(nil), do: 0
  defp height(%Node{height: h}), do: h

  defp rotate_left(%Node{
         value: v,
         count: c,
         left: l,
         right: %Node{value: rv, count: rc, left: rl, right: rr}
       }) do
    h_l = height(l)
    h_rr = height(rr)
    h_rl = height(rl)
    h = 1 + max(h_l, h_rl)

    %Node{
      value: rv,
      count: rc,
      height: 1 + max(h, h_rr),
      left: %Node{value: v, count: c, height: h, left: l, right: rl},
      right: rr
    }
  end

  defp rotate_right(%Node{
         value: v,
         count: c,
         left: %Node{value: lv, count: lc, left: ll, right: lr},
         right: r
       }) do
    h_r = height(r)
    h_l = height(ll)
    h_lr = height(lr)
    h = 1 + max(h_lr, h_r)

    %Node{
      value: lv,
      count: lc,
      height: 1 + max(h_l, h),
      left: ll,
      right: %Node{value: v, count: c, height: h, left: lr, right: r}
    }
  end

  # =====

  def filter(%AVLMultiset{root: root}, fun) do
    filter_node(root, fun, new())
  end

  defp filter_node(nil, _fun, acc_tree), do: acc_tree

  defp filter_node(%Node{value: v, count: c, left: l, right: r}, fun, acc_tree) do
    acc_tree = filter_node(l, fun, acc_tree)

    acc_tree =
      if fun.(v) do
        1..c |> Enum.reduce(acc_tree, fn _, tree -> add(tree, v) end)
      else
        acc_tree
      end

    filter_node(r, fun, acc_tree)
  end

  def map(%AVLMultiset{root: root}, fun) do
    map_node(root, fun, new())
  end

  defp map_node(nil, _fun, acc_tree), do: acc_tree

  defp map_node(%Node{value: v, count: c, left: l, right: r}, fun, acc_tree) do
    acc_tree = map_node(l, fun, acc_tree)
    new_v = fun.(v)
    acc_tree = 1..c |> Enum.reduce(acc_tree, fn _, tree -> add(tree, new_v) end)
    map_node(r, fun, acc_tree)
  end

  def foldl(%AVLMultiset{root: root}, acc, fun) do
    foldl_node(root, acc, fun)
  end

  defp foldl_node(nil, acc, _fun), do: acc

  defp foldl_node(%Node{value: v, count: c, left: l, right: r}, acc, fun) do
    acc = foldl_node(l, acc, fun)
    acc = 1..c |> Enum.reduce(acc, fn _, a -> fun.(v, a) end)
    foldl_node(r, acc, fun)
  end

  def foldr(%AVLMultiset{root: root}, acc, fun) do
    foldr_node(root, acc, fun)
  end

  defp foldr_node(nil, acc, _fun), do: acc

  defp foldr_node(%Node{value: v, count: c, left: l, right: r}, acc, fun) do
    acc = foldr_node(r, acc, fun)
    acc = 1..c |> Enum.reduce(acc, fn _, a -> fun.(v, a) end)
    foldr_node(l, acc, fun)
  end

  def to_list(%AVLMultiset{} = ms) do
    foldr(ms, [], fn x, acc -> [x | acc] end)
  end
end

defimpl Multiset, for: Multiset.AVLMultiset do
  def add(multiset, element), do: AVLMultiset.add(multiset, element)

  def remove(multiset, element), do: AVLMultiset.remove(multiset, element)

  def count(multiset, element), do: AVLMultiset.count(multiset, element)

  def contains?(multiset, element), do: AVLMultiset.contains?(multiset, element)

  def size(multiset), do: AVLMultiset.size(multiset)

  def empty?(multiset), do: AVLMultiset.empty?(multiset)

  def filter(multiset, fun), do: AVLMultiset.filter(multiset, fun)

  def map(multiset, fun), do: AVLMultiset.map(multiset, fun)

  def foldl(multiset, acc, fun), do: AVLMultiset.foldl(multiset, acc, fun)

  def foldr(multiset, acc, fun), do: AVLMultiset.foldr(multiset, acc, fun)

  def union(bag1, bag2), do: AVLMultiset.union(bag1, bag2)
end
