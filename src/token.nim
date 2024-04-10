import lex/location, types

type Token* = ref object of RootObj
  val*: string
  left*: Location
  right*: Location
  size*: int
  typ*: TokenType
