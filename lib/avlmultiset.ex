defmodule AVLMultiset do
  defmodule Node do
    defstruct value: nil, count: 1, height: 1, left: nil, right: nil
  end

  defstruct root: nil, size: 0

  def new(), do: %AVLMultiset{}

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

  def to_list(%AVLMultiset{root: root}),
    do: inorder(root, [])

  # ===== private =====

  defp do_count(nil, _), do: 0

  defp do_count(%Node{value: v, count: c, left: l, right: r}, key) do
    cond do
      key < v -> do_count(l, key)
      key > v -> do_count(r, key)
      true -> c
    end
  end

  defp inorder(nil, acc), do: acc

  defp inorder(%Node{value: v, count: c, left: l, right: r}, acc) do
    acc = inorder(r, acc)
    acc = List.duplicate(v, c) ++ acc
    inorder(l, acc)
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
      d when d > 1 ->
        if height(l.left) >= height(l.right),
          do: rotate_right(%Node{node | height: h}),
          else: rotate_right(%Node{node | height: h, left: rotate_left(l)})

      d when d < -1 ->
        if height(r.right) >= height(r.left),
          do: rotate_left(%Node{node | height: h}),
          else: rotate_right(%Node{node | height: h, right: rotate_right(r)})

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
end
