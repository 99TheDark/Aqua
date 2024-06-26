type 
  Kind* = enum
    Ident
    Type
    TypedIdent
    Number
    Bool
    String
    RawString
    Char
    Range
    Null
    Array
    Map
    Tuple
    Pair
    BinaryOp
    UnaryOp
    Spread
    Decl
    Assign
    ListDestructure
    # TODO: Add TupleDestructure, ArrayDestructure and MapDestructure
    FuncCall
    TagCall
    Access
    SafeAccess
    Index
    Module
    Use
    Visibility
    ControlLabel
    Block
    IfStmt
    ForLoop
    WhileLoop
    DoWhileLoop
    Loop
    # TODO: Add Match statement
    Break
    Continue
    Label
    FuncBody
    Param
    Function
    Return
    Defer
    Yield
    Throw
    Try
    Catch
    Tag
    Field
    Struct
    Assert
    Test
    Cast
    Alias
    Todo
    Comment

  StringElemKind* = enum
    ExprString
    RawString
  
  DeclKind* = enum 
    VarDecl
    LetDecl
  
  VisKind* = enum
    PubVis
    InnVis
    PriVis

proc isDestructure*(self: Kind): bool =
  self == Ident or self == ListDestructure