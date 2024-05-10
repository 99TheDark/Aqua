import ../lex/location, kind, unicode, options, ../types

type Node* = ref object
  case kind*: Kind
    of Null, Module, Use, Continue, Todo:
      discard

    of Ident:
      name*: string

    of Type:
      base*: Node
      optional*: bool

    of TypedIdent:
      iden*: Node
      annot*: Option[Node]

    of Number:
      numVal*: float

    of Bool:
      boolVal*: bool

    of String:
      strElems*: seq[Node]
    
    of RawString:
      rawVal*: string

    of Char:
      charVal*: Rune
    
    of Range:
      rangeStart*: Node
      rangeEnd*: Node
      inclusive*: bool

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
      decIdens*: Node
      decVals*: seq[Node]

    of Assign:
      assIdens*: Node
      assOp*: Option[TokenType]
      assVals*: seq[Node]
    
    of ListDestructure:
      listIdens*: seq[Node]

    of FuncCall:
      callee*: Node
      args*: seq[Node]

    of Access, SafeAccess:
      parent*: Node
      child*: Node
    
    of Index:
      indexable*: Node
      idx*: Node
    
    of Visibility:
      visKind*: VisKind
      visArg*: Node
    
    of ControlLabel:
      ctrlLabel*: Node
      ctrlStmt*: Node
    
    of Block:
      stmts*: seq[Node]

    of IfStmt:
      test*: Node
      then*: Node
      alt*: Option[Node]

    of ForLoop:
      indexers*: seq[Node]
      iter*: Node
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
      breakLabel*: Option[Node]
      breakArg*: Option[Node]
    
    of Label:
      label*: Node

    of FuncBody:
      params*: seq[Node]
      error*: Option[Node]
      ret*: Option[Node]
      body*: Node
    
    of Param:
      parIdens*: seq[Node]
      parAnnot*: Node
      parDefault*: Option[Node]

    of Function:
      fnName*: Option[Node]
      fnBody*: Node
    
    of Return:
      retVal*: Option[Node]
    
    of Defer:
      deferred*: Node
    
    of Yield:
      yieldVal*: Node
    
    of Throw:
      err*: Node
    
    of Try:
      tried*: Node
    
    of Catch:
      caught*: Node
    
    of Assert:
      claim*: Node
    
    of Test:
      testName*: Node
      testBody*: Node
    
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
