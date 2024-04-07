import Token, Location, Type
import unicode

type Lexer* = ref object of RootObj
  code: seq[Rune]
  loc: Location
  tokens*: seq[Token]

# Many private methods for lexing
proc at(self: Lexer): Rune = self.code[self.loc.idx]

proc ahead(self: Lexer, count: int): seq[Rune] =
  let i = self.loc.idx
  self.code[i..<i+count]

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
    let tok = Token(left: self.loc, size: maxLen, typ: symType)
    return (true, tok)

# Important public methods & procedures
# TODO: Use more refs, less copying data over
proc lex*(self: Lexer) =
  var capture: seq[Rune] = @[]
  var capStart = emptyLoc()
  while self.loc.idx < self.code.len():
    let (isSymbol, symbol) = self.symbol()
    if isSymbol:
      #[
        if self.pushIdent(capture, capStart):
          capture.setLen(0)
        
        self.push(symbol)
      ]#
      discard
    else:
      if capture.len() == 0:
        capStart = self.loc

      capture.add(self.at())
      # self.loc.next()

proc newLexer*(src: string): Lexer =
  return Lexer(code: src.toRunes(), loc: emptyLoc(), tokens: @[])
