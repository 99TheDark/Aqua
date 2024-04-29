import tables, std/enumutils, std/re, strutils, strformat

type TokenType* = enum
  # Basic Types
  Identifier
  Number
  Boolean
  String
  Char
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
  Var
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

  # Visibility
  Public
  Private
  Inner

  # Data movement
  Module
  Use

  # Complex types
  Class
  New
  Operator
  Self
  Super
  Trait
  Implement
  Enum
  Function
  Return
  Defer
  Iterator
  Yield
  Distinct

  # Accessor
  Dot
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
  Cast
  Alias
  Macro
  Coroutine
  Todo
  Spread
  Range
  RangeInclusive
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
  "var": Var,
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
  "oper": Operator,
  "self": Self,
  "super": Super,
  "trait": Trait,
  "impl": Implement,
  "enum": Enum,
  "func": Function,
  "return": Return,
  "defer": Defer,
  "iterator": Iterator,
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
  "cast": Cast,
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
  "?.": OptionalChain,
  " ": Whitespace,
  "\t": Whitespace,
  "\v": Whitespace,
  "\l": Whitespace,
  "...": Spread,
  "..": Range,
  "..=": RangeInclusive,
  "??": Nullish,
  "?": Optional,
}

const BinaryOperators* = [
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

proc isLineSeperator*(self: TokenType): bool = 
  self == NewLine or self == Semicolon

proc isLineEnd*(self: TokenType): bool =
  self.isLineSeperator() or self == Eof

proc formatName[T = Ordinal](self: T): string = 
  self.symbolName.replacef(re"(?<=[a-z])([A-Z])", " $1").toLower()

proc invTable[T = Ordinal](arr: openArray[(string, T)]): Table[T, string] =
  var table = initTable[T, string](arr.len())
  var ignored: seq[T] = @[]
  for (key, val) in arr:
    if table.hasKey(val):
      table.del(val)
      ignored.add(val)
    elif val notin ignored:
      table[val] = key
  
  table

let InvKeywords = invTable(Keywords)
let InvSymbols = invTable(Symbols)

proc `$`*(self: TokenType): string =
  if InvKeywords.hasKey(self):
    return fmt"'{InvKeywords[self]}'"
  elif InvSymbols.hasKey(self): 
    return fmt"'{InvSymbols[self]}'"
  elif self == Eof:
    return "end of file"
  else:
    return self.formatName()