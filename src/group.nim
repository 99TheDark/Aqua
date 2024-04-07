import Type

type GroupType* = enum
  String
  Rune
  SingleComment
  MultiComment
  EmbeddedExpr

type Group* = object
  typ*: GroupType
  left*: Type
  right*: Type

# Groups that can start anywhere (so not EmbeddedExpr, which is $() inside a String)
const OpenGroups* = [
  Group(
    typ: SingleComment,
    left: Comment,
    right: NewLine,
  ),
  Group(
    typ: MultiComment,
    left: DoubleQuote,
    right: DoubleQuote,
  ),
  Group(
    typ: String,
    left: DoubleQuote,
    right: DoubleQuote,
  ),
  Group(
    typ: Rune,
    left: Quote,
    right: Quote,
  ),
]
