import ../lex/location, kind, unicode, options, ../types

type Node* = ref object
  case kind*: Kind
    of Null, Continue, Todo:
      discard

    of Ident:
      name*: string

    of Type:
      base*: Node
      option*: bool

    of TypedIdent:
      iden*: Node

    of Number:
      numVal*: float

    of Bool:
      boolVal*: bool

    of String:
      embedExprs*: seq[Node]
      rawStrs*: seq[string]
      strElems*: seq[StringElemKind]

    of RawString:
      rawVal*: string

    of Char:
      charVal*: Rune

    of Array:
      arrList*: seq[Node]

    of Tuple:
      tupList*: seq[Node]
    
    of BinaryOp:
      lhs*: Node
      rhs*: Node
      binop*: TokenType
    
    of UnaryOp:
      arg*: Node
      unop*: TokenType
    
    of Spread:
      multi*: Node

    of Decl:
      decKind*: DeclKind
      decIdens*: seq[Node]
      decVals*: seq[Node]

    of Assign:
      assIdens*: seq[Node]
      assOp*: Option[TokenType]
      assVals*: seq[Node]

    of FuncCall:
      callee*: Node
      args*: seq[Node]

    of Access, SafeAccess, ConstAccess:
      parent*: Node
      child*: Node
    
    of Index:
      indexable*: Node
      idx*: Node
    
    of Block:
      stmts*: seq[Node]

    of IfStmt:
      test*: Node
      then*: Node
      alter*: Node

    of ForLoop:
      indexer*: seq[Node]
      inter*: Node
      forBody*: Node
    
    of WhileLoop:
      whileCond*: Node
      whileBody*: Node
    
    of DoWhileLoop:
      doBody*: Node
      doCond*: Node

    of Loop:
      loopBody*: Node
    
    of Break:
      breakTo*: Node
    
    of Return:
      retVal*: Node
    
    of Defer:
      deferred*: Node
    
    of Yield:
      genVal*: Node
    
    of Throw:
      err*: Node
    
    of Try:
      tried*: Node
    
    of Catch:
      caught*: Node
    
    of Assert:
      claim*: Node
    
    of Test:
      label*: Node
    
    of Cast:
      to*: Node
      casted*: Node
    
    of Alias:
      alias*: Node
      orig*: Node

    of Comment:
      msg*: string
  
  left*: Location
  right*: Location
  # TODO: Add typ* and inserted* when adding type inference/checking
  # inserted*: bool = false # Inserted by the compiler?
