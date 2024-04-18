import ../types

type GroupType* = enum
  StringGroup
  CommentGroup
  MultiCommentGroup
  InterpolateGroup

type Group* = object
  typ*: GroupType
  left*: TokenType = None
  right*: TokenType = None
  inner*: TokenType = None
  recursive*: bool = false
  name*: string

# Groups that can start anywhere (so not InterpolateGroup, which is $() inside a StringGroup)
const OpenGroups* = [
  Group(
    typ: CommentGroup,
    left: CommentStart,
    right: NewLine,
    inner: Comment,
    name: "single-line comment",
  ),
  Group(
    typ: MultiCommentGroup,
    left: MultiCommentStart,
    right: MultiCommentEnd,
    inner: MultiComment,
    recursive: true,
    name: "multi-line comment",
  ),
  Group(
    typ: StringGroup,
    left: DoubleQuote,
    right: DoubleQuote,
    inner: String,
    name: "string",
  ),
]

const ClosedInterpolateGroup* = Group(
  typ: InterpolateGroup, 
  right: RightParen,
  name: "interpolation",
)
