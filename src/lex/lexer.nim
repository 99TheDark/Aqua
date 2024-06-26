import ../token, location, ../types, group, number, ../error, ../parse/message
import unicode, sequtils, strformat
import strutils except Whitespace

# Extend seq[T] to give last/top item
proc top[T](self: seq[T]): T = self[self.len() - 1]

# Lexer
type Lexer* = ref object
  code*: seq[Rune]
  errgen*: ErrorGenerator
  loc: Location
  groupStack: seq[Group]
  numeric: bool
  parenCount: int
  tokens*: seq[Token]

proc panic(self: Lexer, left: Location, right: Location, msg: string) =
  self.errgen.panic(msg, left, right, false)

# Many private methods for lexing
proc lexNorm(self: Lexer): bool =
  if self.groupStack.len() == 0:
    return true

  self.groupStack.top().typ == InterpolateGroup

proc at(self: Lexer): Rune = 
  self.code[self.loc.idx]

proc ahead(self: Lexer, count: int): seq[Rune] =
  let start = self.loc.idx
  let cap = min(start + count, self.code.len())
  self.code[start..<cap]

proc behind(self: Lexer, count: int): seq[Rune] =
  let start = self.loc.idx + 1
  let cap = max(start - count, 0)
  self.code[cap..<start]

proc shouldSkip(self: Lexer, symbol: Token): bool =
  if not self.numeric:
    return false

  # From now on, it is the numeric mode
  if symbol.typ == Dot:
    return true

  if $self.behind(2) == "e-":
    return true

  false

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
  self.numeric = false # Resetting if the identifier is numeric

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
  if self.tokens.len() == 0 or not self.lexNorm():
    return

  let last = self.tokens.top()
  for group in OpenGroups:
    if group.left == last.typ:
      self.groupStack.add(group)
      return

proc addGroup(self: Lexer, group: Group) =
  let left = self.tokens.top().right.clone()
  let right = self.loc.clone()

  # Don't add literally nothing
  if left.idx == right.idx:
    return

  self.tokens.add(Token(
    val: $self.code[left.idx..<right.idx],
    left: left,
    right: right,
    size: right.idx - left.idx,
    typ: group.inner,
  ))

# Important public methods & procedures
proc lex*(self: Lexer): seq[Token] =
  var capture: seq[Rune] = @[]
  var capStart = emptyLoc()
  while self.loc.idx < self.code.len():
    let (isSymbol, symbol) = self.symbol()
    if self.lexNorm():
      if not self.numeric and capture.len() == 0 and self.at().isNumeric():
        self.numeric = true
        continue

      if isSymbol and not self.shouldSkip(symbol):
        if self.addIdent(capture, capStart):
          capture.setLen(0)

        self.add(symbol)

        if symbol.typ == Quote:
          let ch = self.at()
          self.loc.next()

          let (symNext, next) = self.symbol()
          if symNext and next.typ == Quote and $ch != "\n":
            self.loc.prev()
            self.add(Token(
              val: $ch,
              left: self.loc.clone(),
              size: 1,
              typ: Character,
            ))
            self.add(Token(
              val: "'",
              left: self.loc.clone(),
              size: 1,
              typ: Quote,
            ))
          else:
            self.loc.prev()
          continue

        # Don't try to access and compute nothing
        if self.groupStack.len() != 0:
          let group = self.groupStack.top()
          if group.typ == InterpolateGroup:
            self.group()

            if symbol.typ == LeftParen:
              self.parenCount += 1
            elif symbol.typ == RightParen:
              if self.parenCount == 0:
                self.addGroup(group)
                discard self.groupStack.pop()
              else:
                self.parenCount -= 1
      else:
        if capture.len() == 0:
          capStart = self.loc.clone()

        capture.add(self.at())
        self.loc.next()
    else:
      let group = self.groupStack.top()
      if $self.ahead(2) == "$(":
        self.addGroup(group)
        self.add(Token(
          val: "$",
          left: self.loc.clone(),
          size: 1,
          typ: StringInterpolation,
        ))
        self.add(Token(
          val: "(",
          left: self.loc.clone(),
          size: 1,
          typ: LeftParen,
        ))
        self.groupStack.add(ClosedInterpolateGroup)
        continue

      if isSymbol:
        if group.recursive and group.left == symbol.typ:
          self.addGroup(group)
          self.add(symbol)
          self.groupStack.add(group)
        elif group.right == symbol.typ:
          self.addGroup(group)
          self.add(symbol)
          discard self.groupStack.pop()
        elif symbol.typ == NewLine:
          self.loc.col = 0
          self.loc.idx += 1
          self.loc.row += 1
        else:
          self.loc.next()

        continue
      else:
        self.loc.next()

    self.group()

  if self.groupStack.len() == 0:
    discard self.addIdent(capture, capStart)
  else:
    let names = self.groupStack.map(proc(g: Group): string = g.name).list("and")
    let ends = self.groupStack.map(proc(g: Group): TokenType = g.right).list("and")
    let plural = (if self.groupStack.len() == 1: "" else: "s")
    self.panic(self.loc, self.loc, fmt"Unclosed {names}, expected ending{plural} {ends}")

  # Add EOF token as well
  self.tokens.add(Token(
    left: self.loc.clone(),
    right: self.loc.clone(),
    size: 0,
    typ: Eof,
  ))

  self.tokens

proc filter*(self: Lexer) =
  self.tokens = self.tokens.filter(
    proc(tok: Token): bool = tok.typ != Whitespace
  )

proc newLexer*(code: seq[Rune], gen: ErrorGenerator): Lexer =
  Lexer(
    code: code,
    errgen: gen,
    loc: emptyLoc(),
    groupStack: @[],
    numeric: false,
    parenCount: 0,
    tokens: @[],
  )