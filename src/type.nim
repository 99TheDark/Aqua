type Type* = enum
  # Basic Types
  Identifier
  Number
  Boolean
  String
  Rune
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

  # Groups
  Comment
  CommentStart
  MultiComment
  MultiCommentStart
  MultiCommentEnd
  Quote
  DoubleQuote

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
  Operator
  Self
  Super
  Trait
  Implement
  Enum
  Function
  Return
  Defer
  Yield
  Distinct

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

  # Misc
  Whitespace
  Alias
  Macro
  Coroutine
  Todo
  Spread
  Range
  RangeInclusive
  Symbol
  Nullish
  Optional
  StringInterpolation

  # Special
  None
  Eof

# Many constants (groups)
const Keywords* = {
  "true": Boolean,
  "false": Boolean,
  "null": Null,
  "let": Let,
  "const": Const,
  "in": In,
  "if": If,
  "else": Else,
  "for": For,
  "while": While,
  "do": Do,
  "loop": Loop,
  "match": Match,
  "break": Break,
  "continue": Continue,
  "pub": Public,
  "pri": Private,
  "inn": Inner,
  "mod": Module,
  "use": Use,
  "class": Class,
  "new": New,
  "from": From,
  "to": To,
  "oper": Operator,
  "self": Self,
  "super": Super,
  "trait": Trait,
  "impl": Implement,
  "enum": Enum,
  "func": Function,
  "return": Return,
  "defer": Defer,
  "yield": Yield,
  "distinct": Distinct,
  "throw": Throw,
  "try": Try,
  "catch": Catch,
  "error": Error,
  "assert": Assert,
  "test": Test,
  "where": Where,
  "when": When,
  "known": Known,
  "is": Is,
  "isnot": IsNot,
  "alias": Alias,
  "macro": Macro,
  "co": Coroutine,
  "todo": Todo,
}

const Symbols* = {
  ",": Comma,
  ";": Semicolon,
  "\n": NewLine,
  "\r": NewLine,
  "\l": NewLine,
  "(": LeftParen,
  ")": RightParen,
  "[": LeftBracket,
  "]": RightBracket,
  "{": LeftBrace,
  "}": RightBrace,
  "//": CommentStart,
  "/*": MultiCommentStart,
  "*/": MultiCommentEnd,
  "'": Quote,
  "\"": DoubleQuote,
  ":": Colon,
  "=": Assign,
  "+": Addition,
  "-": Subtraction,
  "*": Multiplication,
  "/": Division,
  "^": Exponentiation,
  "%": Modulo,
  "&": And,
  "|": Or,
  "!&": Nand,
  "!|": Nor,
  "^&": Xand,
  "^|": Xor,
  "!": Not,
  ">>": RightShift,
  "<<": LeftShift,
  ">>>": ZeroFillRightShift,
  "<..": CountLeadingZeroes,
  ">..": CountTrailingZeroes,
  "==": Equal,
  "!=": NotEqual,
  ">": GreaterThan,
  "<": LessThan,
  ">=": GreaterThanOrEqual,
  "<=": LessThanOrEqual,
  "+%": WrappedAddition,
  "-%": WrappedSubtraction,
  "*%": WrappedMultiplication,
  "<<%": WrappedLeftShift,
  "=>": FatArrow,
  "@": PatternBinder,
  ".": Dot,
  "::": DoubleColon,
  "?.": OptionalChain,
  " ": Whitespace,
  "\t": Whitespace,
  "\v": Whitespace,
  "...": Spread,
  "..": Range,
  "..=": RangeInclusive,
  "??": Nullish,
  "?": Optional,
}

const Operators* = [
  Addition,
  Subtraction,
  Multiplication,
  Division,
  Exponentiation,
  Modulo,
  And,
  Or,
  Nand,
  Nor,
  Xand,
  Xor,
  Not,
  RightShift,
  LeftShift,
  ZeroFillRightShift,
  CountLeadingZeroes,
  CountTrailingZeroes,
  Equal,
  NotEqual,
  GreaterThan,
  LessThan,
  GreaterThanOrEqual,
  LessThanOrEqual,
  WrappedAddition,
  WrappedSubtraction,
  WrappedMultiplication,
  WrappedLeftShift,
  Nullish,
]
