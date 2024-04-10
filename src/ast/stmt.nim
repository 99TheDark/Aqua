import node, ../types, options, unique, kind

type
  # Literals
  Ident* = ref object of Node
    name*: string

  Number* = ref object of Node
    val*: float

  Bool* = ref object of Node
    val*: bool

  String* = ref object of Node
    exprs*: seq[Node]
    raw*: seq[string]
    elems*: seq[StringElemKind]
    basic*: bool
  
  RawString* = ref object of Node # for testing, external, filepaths, etc
    val*: bool
  
  Rune* = ref object of Node
    val*: Rune

  Null* = ref object of Node

  Array* = ref object of Node
    list*: List
  
  Tuple* = ref object of Node
    list*: List

  # Operations
  BinaryOp* = ref object of Node
    lhs*: Node
    rhs*: Node
    op*: TokenType

  UnaryOp* = ref object of Node
    arg*: Node
    op*: TokenType
  
  Spread* = ref object of Node
    iter*: Node
  
  # Identifier-based
  Decl* = ref object of Node
    kind*: DeclKind
    idens*: List[Ident]
    vals*: List[Node]
  
  Assign* = ref object of Node
    idens*: List[Ident]
    op*: Option[TokenType]
    vals*: List[Node]
  
  FuncCall* = ref object of Node
    callee*: Ident
    args*: List[Node]

  Access* = ref object of Node
    iden*: Ident
    sub*: Ident
  
  SafeAccess* = ref object of Access
  
  ConstAccess* = ref object of Access

  Index* = ref object of Node
    iden*: Ident
    idx*: Node

  # Control flow
  Block* = ref object of Node
    stmts*: seq[Node]

  IfStmt* = ref object of Node
    cond*: Node
    body*: Block
    alt*: Block
  
  ForLoop* = ref object of Node
    iden*: Ident
    iter*: Node
    body*: Node
  
  WhileLoop* = ref object of Node
    cond*: Node
    body*: Block
  
  DoWhileLoop* = ref object of Node
    body*: Block
    cond*: Node
  
  Loop* = ref object of Node
    body*: Block
  
  # TODO: Add Match statement

  Break* = ref object of Node
    to*: Node 
  
  Continue* = ref object of Node

  # TODO: Add Module statement
  # TODO: Add Import statement
  
  # Complex types
  Return* = ref object of Node
    val*: Node
  
  Defer* = ref object of Node
    arg*: Node
  
  Yield* = ref object of Node
    val*: Node

  # TODO: Add classes and everything that comes with them
  # TODO: Add enums and everything that comes with them
  # TODO: Add functions and everything that comes with them

  # Error handling
  Throw* = ref object of Node
    err*: Node
  
  Try* = ref object of Node
    arg*: Node
  
  Catch* = ref object of Node
    val*: Node
  
  Error* = ref object of Node
    iden*: Ident
    errors*: List[Ident]

  # Testing
  Assert* = ref object of Node
    claim*: Node
  
  Test* = ref object of Node
    name*: RawString
  
  # TODO: Add all the generic-based things

  # Miscellaneous
  Comment* = ref object of Node
    msg*: string
  
  Alias* = ref object of Node
    iden*: Ident
    orig*: Node # TODO: Change to eventual Type object
  
  # TODO: Add macro and everything that comes with them
  # TODO: Add coroutines and everything that comes with them

  Todo* = ref object of Node