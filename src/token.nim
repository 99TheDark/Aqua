import Location, Type

type Token* = ref object of RootObj
  val*: string
  left*: Location
  right*: Location
  size*: int
  typ*: Type
