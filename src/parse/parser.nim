import ../ast/[node, kind], ../[token, types, error, todo], message, ../lex/location
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

proc expect(self: Parser, expected: openArray[TokenType]): Token = 
  let tok = self.eat()
  if tok.typ notin expected:
    let last = expected.len() - 1
    let list = expected[0..<last].join() & " or " & $expected[last]
    panic(fmt"Expected {list}, but got {tok.typ} instead")
  
  tok

# List of all the procedures before they are defined
proc parseNode(self: Parser): Node
proc parseStmt(self: Parser): Node
proc parseDecl(self: Parser): Node
proc parseIfStmt(self: Parser): Node
proc parseForLoop(self: Parser): Node
proc parseWhileLoop(self: Parser): Node
proc parseDoWhileLoop(self: Parser): Node
proc parseLoop(self: Parser): Node
proc parseBreak(self: Parser): Node
proc parseContinue(self: Parser): Node
proc parseExpr(self: Parser): Node
proc parseBinaryOp(self: Parser): Node
proc parsePrimary(self: Parser): Node

proc parseBlock(self: Parser): Node =
  let left = self.expect(LeftBrace).left.clone()

  var stmts: seq[Node] = @[]
  while self.tt() != RightBrace:
    if self.tt().isLineSeperator():
      discard self.eat()
      continue

    stmts.add(self.parseNode())
    discard self.expect([NewLine, Semicolon])

  let right = self.expect(RightBrace).right.clone()
  Node(kind: Block, left: left, right: right, stmts: stmts)

# Statements begin the cacade, with keyword-starting statements like 'if' and 'func'
proc parseStmt(self: Parser): Node =
  case self.tt():
    of LeftBrace: return self.parseBlock()
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
    else: return self.parseExpr() 

proc parseDecl(self: Parser): Node =
  todo("declaration")

proc parseIfStmt(self: Parser): Node =
  todo("if statement")

proc parseForLoop(self: Parser): Node =
  todo("for loop")

proc parseWhileLoop(self: Parser): Node =
  todo("while loop")

proc parseDoWhileLoop(self: Parser): Node =
  todo("do while loop")

proc parseLoop(self: Parser): Node =
  let left = self.eat().left.clone()
  let body = self.parseBlock()
  Node(kind: Loop, left: left, right: body.right.clone(), loopBody: body)

proc parseBreak(self: Parser): Node =
  todo("break")

proc parseContinue(self: Parser): Node =
  todo("continue")

# Expressions cascade
proc parseExpr(self: Parser): Node =
  self.parseBinaryOp()

proc parseBinaryOp(self: Parser): Node =
  todo("binary operator")

proc parsePrimary(self: Parser): Node =
  panic(fmt"Expected a statement, got {self.tt()} instead")

# A large cascade of parsing
proc parseNode(self: Parser): Node =
  self.parseStmt()

proc parse*(self: Parser): Node =
  # TODO: Make this parse more than one node
  self.parseNode()

proc newParser*(tokens: seq[Token]): Parser =
  Parser(tokens: tokens, idx: 0)