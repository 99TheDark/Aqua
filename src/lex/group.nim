import ../types

type GroupType* = enum
  StringGroup
  RuneGroup
  CommentGroup
  MultiCommentGroup
  InterpolateGroup

type Group* = object
  typ*: GroupType
  left*: TokenType = None
  right*: TokenType = None
  inner*: TokenType = None
  recursive*: bool = false

# Groups that can start anywhere (so not InterpolateGroup, which is $() inside a StringGroup)
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

const ClosedInterpolateGroup* = Group(typ: InterpolateGroup)
