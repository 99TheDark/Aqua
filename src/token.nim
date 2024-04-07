import Location, Type

type Token* = ref object of RootObj
  val*: string
  left*: Location
  right*: Location
  typ*: Type

proc len*(self: Token): int =
  return self.right.idx - self.left.idx
