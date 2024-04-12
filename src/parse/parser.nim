import ../ast/[node, iden, control], ../[token, types, error, todo]
import strformat

type Parser* = ref object
  tokens: seq[Token]
  idx: int

proc at(self: Parser): Token = self.tokens[self.idx]

proc tt(self: Parser): TokenType = self.at().typ

proc eat(self: Parser): Token = 
  let tok = self.at()
  self.idx += 1
  tok

proc expect(self: Parser, expected: TokenType): Token = 
  let tok = self.eat()
  if tok.typ != expected:
    panic(fmt"Expected {expected}, but got {tok.typ} instead")
  
  tok

proc parseDecl(self: Parser): Decl =
  todo("declaration")

proc parseIfStmt(self: Parser): IfStmt =
  todo("if statement")

proc parseForLoop(self: Parser): ForLoop =
  todo("for loop")

proc parseWhileLoop(self: Parser): WhileLoop =
  todo("while loop")

proc parseDoWhileLoop(self: Parser): DoWhileLoop =
  todo("do while loop")

proc parseLoop(self: Parser): Loop =
  todo("loop")

proc parseBreak(self: Parser): Break =
  todo("break")

proc parseContinue(self: Parser): Continue =
  todo("continue")

# It's really annoying that procs have to be defined top to bottom
proc parseStmt(self: Parser): Node =
  case self.tt():
    of Var, Let: return self.parseDecl()
    of If: return self.parseIfStmt()
    of Else: panic("An else case must be directly proceeding an if statement or if-else case")
    of For: return self.parseForLoop()
    of While: return self.parseWhileLoop()
    of Do: return self.parseDoWhileLoop()
    of Loop: return self.parseLoop()
    # TODO: Implement match
    of Break: return self.parseBreak()
    of Continue: return self.parseContinue()
    # TODO: Implement func
    # TODO: Implement return
    # TODO: Implement class and all its subnodes
    # TODO: Implement enum
    # TODO: Implement generic contraints
    # TODO: Write all the todos for the rest of the statements :P
    else: panic(fmt"Expected a statement, got {self.tt()} instead") # TODO: Make this fallback to parseExpr

# A large cascade of parsing, starting with a ton of statements that start with keywords like 'if' and 'func'
proc parseNode(self: Parser): Node =
  self.parseStmt()

proc parse*(self: Parser): Node =
  # TODO: Make this parse more than one node
  self.parseNode()

proc newParser*(tokens: seq[Token]): Parser =
  Parser(tokens: tokens, idx: 0)