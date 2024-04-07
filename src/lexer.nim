import Token, Location
import unicode

type Lexer* = ref object of RootObj
  code: seq[Rune]
  loc: Location
  tokens*: seq[Token]

# Many private methods for lexing
proc at(self: Lexer, idx: uint): Rune = self.code[idx]

# Important public methods & procedures
proc lex*(self: Lexer) =
  var capture: seq[Rune] = @[]
  var capStart = emptyLoc()
  while self.loc.idx < self.code.len()

proc newLexer*(src: string): Lexer =
  return Lexer(code: src.toRunes(), loc: emptyLoc(), tokens: @[])
