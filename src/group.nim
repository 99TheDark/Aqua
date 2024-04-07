import Type

type GroupType* = enum
  StringGroup
  RuneGroup
  CommentGroup
  MultiCommentGroup
  NumericGroup
  EmbeddedGroup

type Group* = object
  typ*: GroupType
  left*: Type
  right*: Type
  inner*: Type
  recursive*: bool = false

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
    recursive: true,
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
