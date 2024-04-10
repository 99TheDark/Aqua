import node, ../types, base

type
  BinaryOp* = ref object of Node
    lhs*: Node
    rhs*: Node
    op*: TokenType

  UnaryOp* = ref object of Node
    arg*: Node
    op*: TokenType
  
  Spread* = ref object of Node
    iter*: Node
  
  # TODO: Add Module statement
  # TODO: Add Import statement
  
  # TODO: Add classes and everything that comes with them
  # TODO: Add enums and everything that comes with them
  # TODO: Add functions and everything that comes with them
  
  Error* = ref object of Node
    iden*: Ident
    errors*: List[Ident]
  
  # TODO: Add all the generic-based things

  Comment* = ref object of Node
    msg*: string
  
  # TODO: Add macro and everything that comes with them
  # TODO: Add coroutines and everything that comes with them