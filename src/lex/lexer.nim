import ../Token, Location, ../Type, Group, Number
import unicode, sequtils
import strutils except Whitespace

# Extend seq[T] to give last/top item
proc top[T](self: seq[T]): T = self[self.len() - 1]

# Lexer
type Lexer* = ref object of RootObj
  code: seq[Rune]
  loc: Location
  groupStack: seq[Group]
  numeric: bool
  tokens*: seq[Token]

# Many private methods for lexing
proc lexNorm(self: Lexer): bool = self.groupStack.len() == 0

proc at(self: Lexer): Rune = self.code[self.loc.idx]

proc ahead(self: Lexer, count: int): seq[Rune] =
  let start = self.loc.idx
  let cap = min(start + count, self.code.len())
  self.code[start..<cap]

proc add(self: Lexer, tok: Token) =
  self.loc.idx += tok.size
  if tok.typ == NewLine:
    self.loc.row += 1
    self.loc.col = 0
  else:
    self.loc.col += tok.size

  let tok = Token(
    val: tok.val,
    left: tok.left,
    right: self.loc.clone(),
    size: tok.size,
    typ: tok.typ
  )
  self.tokens.add(tok)

proc addIdent(self: Lexer, capture: seq[Rune], capStart: Location): bool =
  let size = capture.len()
  if size != 0:
    var identType = Identifier
    block main:
      for (keyword, typ) in Keywords:
        if keyword == $capture:
          identType = typ
          break main

    let firstChar = ($capture)[0]
    if firstChar.isDigit() or firstChar == '.':
      identType = Number

    let tok = Token(
      val: $capture,
      left: capStart.clone(),
      right: self.loc.clone(),
      size: capture.len(),
      typ: identType,
    )
    self.tokens.add(tok)

    return true

  return false

proc symbol(self: Lexer): (bool, Token) =
  var maxLen = 0
  var symType = Eof
  for (src, typ) in Symbols:
    let length = src.len()
    if length > maxLen and $self.ahead(length) == src:
      maxLen = length
      symType = typ

  if maxLen == 0:
    return (false, Token())
  else:
    let tok = Token(
      val: $self.ahead(maxLen),
      left: self.loc.clone(),
      size: maxLen,
      typ: symType
    )
    return (true, tok)

proc group(self: Lexer) =
  # Stop index out of bounds errors
  if self.tokens.len() == 0 or self.groupStack.len() != 0:
    return

  let last = self.tokens.top()
  for group in OpenGroups:
    if group.left == last.typ:
      self.groupStack.add(group)
      return

proc addGroup(self: Lexer, group: Group) =
  let left = self.tokens.top().right.clone()
  let right = self.loc.clone()
  self.tokens.add(Token(
    val: $self.code[left.idx..<right.idx],
    left: left,
    right: right,
    size: right.idx - left.idx,
    typ: group.inner,
  ))

# Important public methods & procedures
proc lex*(self: Lexer) =
  var capture: seq[Rune] = @[]
  var capStart = emptyLoc()
  while self.loc.idx < self.code.len():
    let (isSymbol, symbol) = self.symbol()
    if self.lexNorm:
      if not self.numeric and capture.len() == 0 and self.at().isNumeric():
        self.numeric = true
        capStart = self.loc.clone()
        echo "It's number time ", self.at()
        continue

      if isSymbol and (not self.numeric or symbol.typ != Dot):
        if self.addIdent(capture, capStart):
          capture.setLen(0)

        self.add(symbol)
      else:
        if capture.len() == 0:
          capStart = self.loc.clone()

        capture.add(self.at())
        self.loc.next()
    else:
      let group = self.groupStack.top()
      if isSymbol:
        if group.recursive and group.left == symbol.typ:
          self.addGroup(group)
          self.add(symbol)
          self.groupStack.add(group)
        elif group.right == symbol.typ:
          self.addGroup(group)
          self.add(symbol)
          discard self.groupStack.pop()
        else:
          self.loc.next()
        continue
      else:
        self.loc.next()

    self.group()

  discard self.addIdent(capture, capStart)

  # Add EOF token as well
  self.tokens.add(Token(
    left: self.loc.clone(),
    right: self.loc.clone(),
    size: 0,
    typ: Eof,
  ))

proc filter*(self: Lexer) =
  self.tokens = self.tokens.filter(
    proc(tok: Token): bool = tok.typ != Whitespace
  )

proc newLexer*(src: string): Lexer =
  Lexer(
    code: src.toRunes(),
    loc: emptyLoc(),
    groupStack: @[],
    numeric: false,
    tokens: @[],
  )