import Type

type GroupType* = enum
  StringGroup
  RuneGroup
  CommentGroup
  MultiCommentGroup
  EmbeddedGroup

type Group* = object
  typ*: GroupType
  left*: Type
  right*: Type
  inner*: Type

# Groups that can start anywhere (so not EmbeddedGroup, which is $() inside a StringGroup)
const OpenGroups* = [
  Group(
    typ: CommentGroup,
    left: CommentStart,
    right: NewLine,
    inner: Comment,
  ),
  Group(
    typ: MultiCommentGroup,
    left: MultiCommentStart,
    right: MultiCommentEnd,
    inner: MultiComment,
  ),
  Group(
    typ: StringGroup,
    left: DoubleQuote,
    right: DoubleQuote,
    inner: String,
  ),
  Group(
    typ: RuneGroup,
    left: Quote,
    right: Quote,
    inner: Rune,
  ),
]
