import node, base, kind, unique, options, ../types

type
  Decl* = ref object of Node
    kind*: DeclKind
    idens*: List[TypedIdent]
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