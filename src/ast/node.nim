import ../lex/location

type Node* = ref object of RootObj
  left*: Location
  right*: Location
  # TODO: Add typ* and inserted* when adding type inference/checking
  # inserted*: bool = false # Inserted by the compiler?
