defmodule AvlBag do
  defmodule Node do
    defstruct value: nil, height: 0, left: nil, right: nil, count: 0
  end

  defstruct root: %Node{}

  def new(), do: %AvlBag{}

  defp rotate_left() do

  end

  defp rotate_right() do

  end

  defp find(bag, element) when %Node{} = elemet do

  end
end

defimpl Multiset, for: AvlBag do
end
