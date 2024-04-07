import Token, Location, Type
import unicode

type Lexer* = ref object of RootObj
  code: seq[Rune]
  loc: Location
  tokens*: seq[Token]

# Many private methods for lexing
proc at(self: Lexer, idx: uint): Rune = self.code[idx]

proc symbol(self: Lexer): (bool, Token) =
  var maxLen = 0
  var successfulPattern = Eof
  for pattern in Symbols:
    echo pattern

# Important public methods & procedures
proc lex*(self: Lexer) =
  var capture: seq[Rune] = @[]
  var capStart = emptyLoc()
  while self.loc.idx < self.code.len():
    let (isSymbol, symbol) = self.symbol()

proc newLexer*(src: string): Lexer =
  return Lexer(code: src.toRunes(), loc: emptyLoc(), tokens: @[])
