import ../ast/[node, kind, mapping], ../[token, types, error], message, ../lex/location, ../operators
import strformat, strutils, unicode, options

type 
  Parser* = ref object
    errgen*: ErrorGenerator
    tokens: seq[Token]
    idx: int
  
  Generator = proc(self: Parser): Node

proc gen(fn: proc(self: Parser): Node): Option[Generator] =
  some(Generator(fn))

# Parser methods
proc panic(self: Parser, tok: Token, msg: string) =
  self.errgen.panic(msg, tok.left, tok.right)

proc at(self: Parser): Token = self.tokens[self.idx]

proc tt(self: Parser): TokenType = self.at().typ

proc eat(self: Parser): Token = 
  let tok = self.at()
  self.idx += 1
  tok

proc pattern(self: Parser, next: openArray[TokenType]): bool =
  for idx, wanted in next:
    let i = self.idx + idx
    if i >= self.tokens.len():
      return false

    if wanted != self.tokens[i].typ:
      return false
  
  true

proc start(self: Parser): Location =
  self.eat().left.clone()

proc expect(self: Parser, expected: TokenType): Token = 
  let tok = self.eat()
  if tok.typ != expected:
    self.panic(tok, fmt"Expected {expected}, but got {tok.typ} instead")
  
  tok

proc expect(self: Parser, expected: openArray[TokenType], canTerminate: bool = false): Token = 
  let tok = self.eat()
  if tok.typ notin expected and tok.typ != Eof:
    let list = expected.list("or")
    self.panic(tok, fmt"Expected {list}, but got {tok.typ} instead")
  
  tok

proc ignore(self: Parser): bool =
  let typ = self.tt()
  if typ.isLineSeperator():
    discard self.eat()
    return true

  if typ == CommentStart:
    discard self.eat()
    discard self.expect(Comment)
    return true

  if typ == MultiCommentStart:
    discard self.eat()
    var brace = 1
    while brace != 0:
      case self.eat().typ
        of MultiCommentStart: brace += 1
        of MultiCommentEnd: brace -= 1
        else: discard
    return true
  
  false

# List of all the procedures before they are defined
proc parseNode(self: Parser): Node
proc parseStmt(self: Parser, fallback: Option[Generator] = none(Generator)): Node
proc parseLookaheadStmt(self: Parser): Node
proc parseDecl(self: Parser): Node
proc parseIfStmt(self: Parser): Node
proc parseForLoop(self: Parser): Node
proc parseWhileLoop(self: Parser): Node
proc parseDoWhileLoop(self: Parser): Node
proc parseLoop(self: Parser): Node
proc parseBreak(self: Parser): Node
proc parseContinue(self: Parser): Node
proc parseReturn(self: Parser): Node
proc parseVisibility(self: Parser): Node
proc parseExpr(self: Parser): Node
proc parseComparative(self: Parser): Node
proc parseLogical(self: Parser): Node
proc parseShifting(self: Parser): Node
proc parseAdditive(self: Parser): Node
proc parseMultiplicative(self: Parser): Node
proc parseExponentiative(self: Parser): Node
proc parseRange(self: Parser): Node
proc parseFuncCall(self: Parser): Node
proc parseUnary(self: Parser): Node
proc parseAccessive(self: Parser): Node
proc parsePrimary(self: Parser): Node

# More general parsing
proc parseBlock(self: Parser): Node =
  let left = self.expect(LeftBrace).left.clone()

  var stmts: seq[Node] = @[]
  while self.tt() != RightBrace:
    if self.ignore(): continue

    stmts.add(self.parseNode())
    if self.tt() != RightBrace:
      discard self.expect([NewLine, Semicolon], canTerminate=true)

  let right = self.expect(RightBrace).right.clone()
  Node(kind: Block, left: left, right: right, stmts: stmts)

proc parseList(self: Parser, node: Generator): seq[Node] =
  var list: seq[Node] = @[]
  while true:
    if self.tt().isLineSeperator():
      discard self.eat()
      continue

    list.add(self.node())
    if self.tt() == Comma:
      discard self.eat()
    else:
      break
  
  list

proc parseBinaryOp(self: Parser, catagory: openArray[TokenType], next: Generator): Node =
  var lhs = self.parseStmt(some(next))
  while self.tt() in catagory:
    let tok = self.eat()
    let rhs = self.parseStmt(some(next))

    lhs = Node(
      kind: BinaryOp, 
      left: lhs.left.clone(), 
      right: rhs.right.clone(), 
      lhs: lhs, 
      rhs: rhs, 
      binOp: tok.typ
    )
  
  lhs

proc parseIdent(self: Parser): Node =
  let tok = self.expect(Identifier)
  Node(kind: Ident, left: tok.left.clone(), right: tok.right.clone(), name: tok.val)

proc parseType(self: Parser): Node =
  let base = self.parseIdent()
  let left = base.left.clone()
  if self.tt() == Optional:
    let opt = self.eat()
    Node(kind: Type, left: left, right: opt.right.clone(), base: base, optional: true)
  else:
    Node(kind: Type, left: left, right: base.right.clone(), base: base, optional: false)

proc parseTypedIdent(self: Parser): Node = 
  let iden = self.parseIdent()
  let (annot, right) = (
    if self.tt() == Colon:
      discard self.eat()
      let typ = self.parseType()
      (some(typ), typ.right.clone())
    else:
      (none(Node), iden.right.clone())
  )
  Node(kind: TypedIdent, left: iden.left.clone(), right: right, iden: iden, annot: annot)

# Statements begin the cacade, with keyword-starting statements like 'if' and 'func'
proc parseStmt(self: Parser, fallback: Option[Generator] = none(Generator)): Node =
  return (
    case self.tt():
      of LeftBrace: self.parseBlock()
      of Let, Var: self.parseDecl()
      of If: self.parseIfStmt()
      of Else: 
        self.panic(self.at(), "An else case must be directly proceeding an if statement or if-else case") 
        Node()
      of For: self.parseForLoop()
      of While: self.parseWhileLoop()
      of Do: self.parseDoWhileLoop()
      of Loop: self.parseLoop()
      # TODO: Implement match
      of Break: self.parseBreak()
      of Continue: self.parseContinue()
      of Return: self.parseReturn()
      # TODO: Implement func
      # TODO: Implement return
      # TODO: Implement class and all its subnodes
      # TODO: Implement enum
      # TODO: Implement generic contraints
      # TODO: Write all the todos for the rest of the statements :P
      of Public, Inner, Private: self.parseVisibility()
      else: 
        if fallback.isNone():
          self.parseLookaheadStmt()
        else:
          let next = fallback.unsafeGet()
          self.next()
  )

proc parseDecl(self: Parser): Node =
  let kind = self.eat()
  let idens = self.parseList(parseTypedIdent)
  discard self.expect(Assign)
  let vals = self.parseList(parseNode)
  Node(
    kind: Decl, 
    left: kind.left.clone(), 
    right: vals[^1].right.clone(), 
    decKind: mapDecl(kind.typ),
    decIdens: idens, 
    decVals: vals,
  )

#[
  let oper = (
    if self.tt() in BinaryOperators: 
      some(self.eat()) 
    else: 
      none(Token)
  )
]#

proc parseIfStmt(self: Parser): Node =
  let left = self.start()
  let test = self.parseExpr()
  let body = self.parseBlock()
  
  let (right, alt) = (
    if self.tt() == Else:
      let left = self.start()
      let alt = (if self.tt() == If: self.parseIfStmt() else: self.parseBlock())
      alt.left = left
      (alt.right.clone(), some(alt))
    else:
      (body.right.clone(), none(Node))
  )

  return Node(
    kind: IfStmt, 
    left: left, 
    right: right, 
    test: test, 
    then: body,
    alt: alt
  )

proc parseForLoop(self: Parser): Node =
  let left = self.start()
  let indexers = self.parseList(parseIdent)
  discard self.expect(In)
  let iter = self.parseExpr()
  let body = self.parseBlock()
  Node(
    kind: ForLoop, 
    left: left, 
    right: body.right.clone(), 
    indexers: indexers, 
    iter: iter,
    forBody: body,
  )

proc parseWhileLoop(self: Parser): Node =
  let left = self.start()
  let cond = self.parseExpr()
  let body = self.parseBlock()
  Node(kind: WhileLoop, left: left, right: body.right.clone(), whileCond: cond, whileBody: body)

proc parseDoWhileLoop(self: Parser): Node =
  let left = self.start()
  let body = self.parseBlock()
  discard self.expect(While)
  let cond = self.parseExpr()
  Node(kind: DoWhileLoop, left: left, right: cond.right.clone(), doBody: body, doCond: cond)

proc parseLoop(self: Parser): Node =
  let left = self.start()
  let body = self.parseBlock()
  Node(kind: Loop, left: left, right: body.right.clone(), loopBody: body)

proc parseBreak(self: Parser): Node =
  let start = self.eat()
  let label = (if self.tt().isLineEnd(): none(Node) else: some(self.parseNode())) 
  let arg = (if self.tt().isLineEnd(): none(Node) else: some(self.parseNode())) 
  let right = (
    if label.isSome(): 
      label.unsafeGet().right 
    elif arg.isSome(): 
      arg.unsafeGet().right 
    else: 
      start.right
  ).clone()

  Node(kind: Break, left: start.left.clone(), right: right, breakArg: arg)

proc parseContinue(self: Parser): Node =
  let tok = self.eat()
  Node(kind: Continue, left: tok.left.clone(), right: tok.right.clone())

proc parseReturn(self: Parser): Node =
  discard

proc parseVisibility(self: Parser): Node =
  let tok = self.eat()
  let arg = self.parseNode()
  Node(
    kind: Visibility, 
    left: tok.left.clone(), 
    right: arg.right.clone(), 
    visKind: mapVis(tok.typ),
    visArg: arg,
  )

proc parseLookaheadStmt(self: Parser): Node =
  if self.pattern([Quote, Identifier, Colon]):
    let left = self.start()
    let label = self.parseIdent()
    discard self.eat()

    while self.tt().isLineSeperator():
      discard self.eat()

    let labeled = self.parseStmt()
    return Node(
      kind: ControlLabel,
      left: left,
      right: labeled.right.clone(),
      ctrlLabel: label,
      ctrlStmt: labeled,
    )
  
  self.parseExpr()

# Expressions cascade
proc parseExpr(self: Parser): Node =
  self.parseComparative()

proc parseComparative(self: Parser): Node = 
  self.parseBinaryOp(Comparative, parseLogical)

proc parseLogical(self: Parser): Node =
  self.parseBinaryOp(Logical, parseShifting)

proc parseShifting(self: Parser): Node =
  self.parseBinaryOp(Shifting, parseAdditive)

proc parseAdditive(self: Parser): Node =
  self.parseBinaryOp(Additive, parseMultiplicative)

proc parseMultiplicative(self: Parser): Node =
  self.parseBinaryOp(Multiplicative, parseExponentiative)

proc parseExponentiative(self: Parser): Node = 
  self.parseBinaryOp(Exponentiative, parseRange)

proc parseRange(self: Parser): Node =  
  let left = self.parseFuncCall()
  let (isRange, inclusive) = (
    case self.tt()
      of Range: (true, false)
      of RangeInclusive: (true, true)
      else: (false, false)
  )
  if isRange:
    discard self.eat()
    let right = self.parseFuncCall()
    return Node(
      kind: Range, 
      left: left.left.clone(),
      right: right.right.clone(),
      rangeStart: left, 
      rangeEnd: right, 
      inclusive: inclusive,
    )

  left

proc parseFuncCall(self: Parser): Node = 
  let left = self.parseUnary()
  if self.tt() == LeftParen:
    discard self.eat()
    let args = self.parseList(parseNode)
    let right = self.expect(RightParen).right.clone()
    return Node(
      kind: FuncCall,
      left: left.left.clone(),
      right: right,
      callee: left,
      args: args,
    )
  left

proc parseUnary(self: Parser): Node =
  if self.tt() in Prefixing:
    let op = self.eat()
    let arg = self.parseStmt(gen(parseAccessive))
    return Node(
      kind: UnaryOp, 
      left: op.left.clone(), 
      right: arg.right.clone(), 
      arg: arg, 
      unop: op.typ,
    )
  
  self.parseAccessive()

proc parseAccessive(self: Parser): Node =
  self.parseBinaryOp(Accessive, parsePrimary)

proc parsePrimary(self: Parser): Node =
  let tok = self.at()
  let left = tok.left.clone()
  return (
    case tok.typ:
      of Boolean: 
        # TODO: Split into seperate procedure
        discard self.eat()
        Node(kind: Bool, left: left, right: tok.right.clone(), boolVal: tok.val == "true") 
      
      of Null:
        discard self.eat()
        Node(kind: Null, left: left, right: tok.right.clone())
      
      of Number:
        # TODO: Use far better numerical parser
        discard self.eat()
        Node(kind: Number, left: left, right: tok.right.clone(), numVal: tok.val.parseFloat())
      
      of DoubleQuote:
        # TODO: Seperate into seperate procedure, like everything else
        discard self.eat()
        var elems: seq[Node] = @[]
        while self.tt() != DoubleQuote:
          let cur = self.eat()
          case cur.typ:
            of String:
              elems.add(Node(
                kind: RawString, 
                left: cur.left.clone(), 
                right: cur.right.clone(), 
                rawVal: cur.val,
              ))
            of StringInterpolation:
              discard self.expect(LeftParen)
              while self.ignore(): discard
              let interpolated = self.parseNode()
              discard self.expect(RightParen)
              elems.add(interpolated)
            else:
              self.panic(cur, fmt"Expected a string or string interpolation, but got {cur.typ} instead")
        let right = self.expect(DoubleQuote).right.clone()
        
        Node(kind: String, left: left, right: right, strElems: elems)
      
      of Quote:
        # TODO: Split into seperate procedure
        discard self.eat()
        if self.tt() == Char:
          let ch = self.eat().val
          let endq = self.expect(Quote)
          Node(kind: Char, left: left, right: endq.right.clone(), charVal: ch.toRunes()[0])
        else:
          let label = self.parseIdent()
          Node(kind: Label, left: left, right: label.right.clone(), label: label)
      
      of Identifier:
        self.parseIdent()
      
      of LeftParen:
        discard self.eat()
        let inner = self.parseNode()
        discard self.expect(RightParen)
        inner

      else: 
        self.panic(tok, fmt"Expected a statement, got {self.tt()} instead")
        Node() # Return something, even if an error will immediately be raised
  )

# A large cascade of parsing
proc parseNode(self: Parser): Node =
  self.parseStmt()

# TODO: Change to return a Program object rather than just a seq[Node]
proc parse*(self: Parser): seq[Node] =
  var nodes: seq[Node] = @[]
  while self.tt() != Eof:
    if self.ignore(): continue

    nodes.add(self.parseNode())
    discard self.expect([NewLine, Semicolon], canTerminate=true)

  nodes

proc newParser*(tokens: seq[Token], gen: ErrorGenerator): Parser =
  Parser(errgen: gen, tokens: tokens, idx: 0)