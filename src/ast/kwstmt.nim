import node, base, literal

type
  Return* = ref object of Node
    val*: Node
  
  Defer* = ref object of Node
    arg*: Node
  
  Yield* = ref object of Node
    val*: Node

  Throw* = ref object of Node
    err*: Node
  
  Try* = ref object of Node
    arg*: Node
  
  Catch* = ref object of Node
    val*: Node

  Assert* = ref object of Node
    claim*: Node
  
  Test* = ref object of Node
    name*: RawString
  
  Cast* = ref object of Node
    to*: Node
    arg*: Node
  
  Alias* = ref object of Node
    iden*: Ident
    orig*: Node
  
  Todo* = ref object of Node