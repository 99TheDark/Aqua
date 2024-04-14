import ../ast/[node, kind], ../[token, types, error, todo], message, ../lex/location, ../operators
import strformat, strutils, unicode

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

proc expect(self: Parser, expected: openArray[TokenType], canTerminate: bool = false): Token = 
  let tok = self.eat()
  if tok.typ notin expected and tok.typ != Eof:
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
proc parseAdditive(self: Parser): Node
proc parseMultiplicative(self: Parser): Node
proc parseExponentiative(self: Parser): Node
proc parsePrimary(self: Parser): Node

# More general parsing
proc parseBlock(self: Parser): Node =
  let left = self.expect(LeftBrace).left.clone()

  var stmts: seq[Node] = @[]
  while self.tt() != RightBrace:
    if self.tt().isLineSeperator():
      discard self.eat()
      continue

    stmts.add(self.parseNode())
    if self.tt() != RightBrace:
      discard self.expect([NewLine, Semicolon], canTerminate=true)

  let right = self.expect(RightBrace).right.clone()
  Node(kind: Block, left: left, right: right, stmts: stmts)

proc parseList(self: Parser, node: proc(self: Parser): Node): seq[Node] =
  var list = @[self.node()]
  while self.tt() == Comma:
    discard self.eat()
    while self.tt().isLineSeperator():
      discard self.eat()

    list.add(self.node())
  
  list

proc parseBinaryOp(self: Parser, catagory: openArray[TokenType], next: proc(self: Parser): Node): Node =
  var lhs = self.next()
  while self.tt() in catagory:
    let tok = self.eat()
    let rhs = self.next()

    lhs = Node(
      kind: BinaryOp, 
      left: lhs.left.clone(), 
      right: rhs.right.clone(), 
      lhs: lhs, 
      rhs: rhs, 
      binOp: tok.typ
    )
  
  lhs

# Statements begin the cacade, with keyword-starting statements like 'if' and 'func'
proc parseStmt(self: Parser): Node =
  # Switch to return (case self.tt(): ... )?
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
  let left = self.eat().left.clone()
  let idens = self.parseList(
    proc(self: Parser): Node = 
      let tok = self.expect(Identifier)
      Node(kind: Ident, left: tok.left.clone(), right: tok.right.clone(), name: tok.val)
  )
  discard self.expect(Assign)
  let vals = self.parseList(parseNode)
  Node(kind: Decl, left: left, right: vals[^1].right, decIdens: idens, decVals: vals)

#[
  let oper = (
    if self.tt() in BinaryOperators: 
      some(self.eat()) 
    else: 
      none(Token)
  )
]#

proc parseIfStmt(self: Parser): Node =
  todo("if statement")

proc parseForLoop(self: Parser): Node =
  todo("for loop")

proc parseWhileLoop(self: Parser): Node =
  # TODO: Implement a shorthand for self.eat().left.clone() and self.eat().right.clone()
  let left = self.eat().left.clone()
  let cond = self.parseExpr()
  let body = self.parseBlock()
  Node(kind: WhileLoop, left: left, right: body.right.clone(), whileCond: cond, whileBody: body)

proc parseDoWhileLoop(self: Parser): Node =
  let left = self.eat().left.clone()
  let body = self.parseBlock()
  discard self.expect(While)
  let cond = self.parseExpr()
  Node(kind: DoWhileLoop, left: left, right: cond.right.clone(), doBody: body, doCond: cond)

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
  self.parseAdditive()

proc parseAdditive(self: Parser): Node =
  self.parseBinaryOp(Additive, parseMultiplicative)

proc parseMultiplicative(self: Parser): Node =
  self.parseBinaryOp(Multiplicative, parseExponentiative)

proc parseExponentiative(self: Parser): Node = 
  self.parseBinaryOp(Exponentiative, parsePrimary)

proc parsePrimary(self: Parser): Node =
  let tok = self.eat()
  return (
    case tok.typ:
      of Boolean: 
        Node(kind: Bool, left: tok.left.clone(), right: tok.right.clone(), boolVal: tok.val == "true") 
      
      of Number:
        Node(kind: Number, left: tok.left.clone(), right: tok.right.clone(), numVal: tok.val.parseFloat())
      
      of Quote:
        let ch = self.expect(Char).val
        let endq = self.expect(Quote)
        Node(kind: Char, left: tok.left.clone(), right: endq.right.clone(), charVal: ch.toRunes()[0])

      else: 
        panic(fmt"Expected a statement, got {self.tt()} instead")
        Node() # Return something, even if an error will immediately be raised
  )

# A large cascade of parsing
proc parseNode(self: Parser): Node =
  self.parseStmt()

proc parse*(self: Parser): Node =
  # TODO: Make this parse more than one node
  self.parseNode()

proc newParser*(tokens: seq[Token]): Parser =
  Parser(tokens: tokens, idx: 0)