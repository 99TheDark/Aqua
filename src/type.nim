type Type* = enum
  # Basic Types
  Identifier,
  Number,
  Boolean,
  String,
  Null,

  # Delimiters
  Comma,
  Semicolon,
  NewLine,

  # Wrappers
  LeftParen,
  RightParen,
  LeftBracket,
  RightBracket,
  LeftBrace,
  RightBrace,

  # Declaration
  Let,
  Const,
  Colon,
  Assign,

  # Binary operators

  # Unary operators

  # Comparisons
  In,

  # Control flow
  If,
  Else,
  For,
  While,
  Do,
  Loop,
  Match,
  Break,
  Continue,

  # Visibility and data movement
  Public,
  Private,
  Inner,
  Module,
  Use,

  # Complex types
  Class,
  New,
  From,
  To,
  Oper,
  Self,
  Super,
  Trait,
  Implement,
  Enum,
  Function,
  Return,
  Defer,
  Yield,

  # Error handling
  Throw,
  Try,
  Catch,
  Error,

  # Testing
  Assert,
  Test,

  # Generics
  Where,
  When,
  Known,
  Is,
  IsNot,

  # Misc
  Whitespace,
  Alias,
  Macro,
  Co,
  Todo,
  EOF,
