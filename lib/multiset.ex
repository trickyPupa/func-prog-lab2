defprotocol Multiset do
  def add(bag, element)
  def count(bag, element)
  def size(bag)
  def remove(bag, element)
  def contains?(bag, element)
  def empty?(bag)
end
