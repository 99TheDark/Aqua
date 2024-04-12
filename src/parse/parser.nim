import ../ast/node, ../token, ../types, ../error
import strformat

type Parser* = ref object
  tokens: seq[Token]
  idx: int

proc at(self: Parser): Token = self.tokens[self.idx]

proc eat(self: Parser): Token = 
  let tok = self.at()
  self.idx += 1
  tok

proc expect(self: Parser, expected: TokenType): Token = 
  let tok = self.eat()
  if tok.typ != expected:
    panic(fmt"Expected {expected}, but got {tok.typ} instead")
  
  tok

proc parse*(self: Parser): Node =
  discard

proc newParser*(tokens: seq[Token]): Parser =
  Parser(tokens: tokens, idx: 0)