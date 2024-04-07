type Type* = enum
  # Basic Types
  Identifier
  Number
  Boolean
  String
  Null

  # Delimiters
  Comma
  Semicolon
  NewLine

  # Wrappers
  LeftParen
  RightParen
  LeftBracket
  RightBracket
  LeftBrace
  RightBrace

  # Declaration
  Let
  Const
  Colon
  Assign

  # Numerical operators
  Addition
  Subtraction
  Multiplication
  Division
  Exponentiation
  Modulo

  # Logical operators
  And
  Or
  Nand
  Nor
  Xand
  Xor
  Not

  # Bitwise operators
  RightShift
  LeftShift
  ZeroFillRightShift
  CountLeadingZeroes
  CountTrailingZeroes

  # Comparisons
  Equal
  NotEqual
  GreaterThan
  LessThan
  GreaterThanOrEqual
  LessThanOrEqual
  In

  # Wrapped operators
  WrappedAddition
  WrappedSubtraction
  WrappedMultiplication
  WrappedLeftShift

  # Control flow
  If
  Else
  For
  While
  Do
  Loop
  Match
  FatArrow
  PatternBinder
  Break
  Continue

  # Visibility and data movement
  Public
  Private
  Inner
  Module
  Use

  # Complex types
  Class
  New
  From
  To
  Oper
  Self
  Super
  Trait
  Implement
  Enum
  Function
  Return
  Defer
  Yield

  # Accessor
  Dot
  DoubleColon
  OptionalChain

  # Error handling
  Throw
  Try
  Catch
  Error

  # Testing
  Assert
  Test

  # Generics
  Where
  When
  Known
  Is
  IsNot

  # Labels
  ArrayLabel
  TupleLabel

  # Misc
  Whitespace
  Alias
  Macro
  Co
  Todo
  Spread
  Range
  Symbol
  Nullish
  Optional
  EOF
