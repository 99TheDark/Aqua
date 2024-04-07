import Token, Location, Type
import unicode
import sequtils

type Lexer* = ref object of RootObj
  code: seq[Rune]
  loc: Location
  tokens*: seq[Token]

# Many private methods for lexing
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
    # TODO: Add number parsing, etc
    var identType = Identifier
    block main:
      for (keyword, typ) in Keywords:
        if keyword == $capture:
          identType = typ
          break main

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

# Important public methods & procedures
# TODO: Use more refs, less copying data over
proc lex*(self: Lexer) =
  var capture: seq[Rune] = @[]
  var capStart = emptyLoc()
  while self.loc.idx < self.code.len():
    let (isSymbol, symbol) = self.symbol()
    if isSymbol:
      if self.addIdent(capture, capStart):
        capture.setLen(0)

      self.add(symbol)
    else:
      if capture.len() == 0:
        capStart = self.loc.clone()

      capture.add(self.at())
      self.loc.next()

  discard self.addIdent(capture, capStart)

  # Add EOF token as well
  self.tokens.add(Token(
    left: self.loc.clone(),
    right: self.loc.clone(),
    size: 0,
    typ: Eof
  ))

proc filter*(self: Lexer) =
  self.tokens = self.tokens.filter(
    proc(tok: Token): bool =
    tok.typ != Whitespace
  )

proc newLexer*(src: string): Lexer =
  return Lexer(code: src.toRunes(), loc: emptyLoc(), tokens: @[])
