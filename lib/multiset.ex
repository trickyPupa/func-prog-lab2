defprotocol Multiset do
  def add(bag, element)
  def count(bag, element)
  def size(bag)
  def remove(bag, element)
  def contains?(bag, element)
  def empty?(bag)
  def filter(bag, fun)
  def map(bag, fun)
  def foldl(bag, acc, fun)
  def foldr(bag, acc, fun)
end
