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
    Tuple
    BinaryOp
    UnaryOp
    Spread
    Decl
    Assign
    FuncCall
    Access
    SafeAccess
    ConstAccess
    Index
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
    Return
    Defer
    Yield
    Throw
    Try
    Catch
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
  