import ../ast/[node, kind, mapping], ../[token, types, error], message, ../lex/location, ../operators, ../todo
import strformat, strutils, unicode, options

type 
  Parser* = ref object
    errgen*: ErrorGenerator
    tokens: seq[Token]
    idx: int
  
  Generator = proc(self: Parser): Node

proc gen(fn: proc(self: Parser): Node): Option[Generator] =
  some(Generator(fn))

proc gen(fn: proc(self: Parser, fallback: Option[Generator] = none(Generator)): Node): Generator =
  proc(self: Parser): Node = self.fn()

# Parser methods
proc panic(self: Parser, tok: Token, msg: string, fallback: bool = false) =
  self.errgen.panic(msg, tok.left.clone(), tok.right.clone(), fallback)

proc at(self: Parser): Token = self.tokens[self.idx]

proc tt(self: Parser): TokenType = self.at().typ

proc eat(self: Parser): Token = 
  let tok = self.at()
  if self.idx < self.tokens.len() - 1:
    self.idx += 1
  
  tok

proc attempt(self: Parser, trial: Generator, backup: Generator): Node =
  let idx = self.idx
  try:
    self.trial()
  except:
    self.idx = idx
    self.backup()

#[ proc peek(self: Parser, ahead: int = 1): TokenType =
  let idx = self.idx + ahead
  if idx < self.tokens.len(): self.tokens[idx].typ else: None ]#

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
proc parseNode(self: Parser, fallback: Option[Generator] = none(Generator)): Node
proc parseStmt(self: Parser): Node
proc parseLookahead(self: Parser): Node
proc parseDecl(self: Parser): Node
proc parseIfStmt(self: Parser): Node
proc parseForLoop(self: Parser): Node
proc parseWhileLoop(self: Parser): Node
proc parseDoWhileLoop(self: Parser): Node
proc parseLoop(self: Parser): Node
proc parseBreak(self: Parser): Node
proc parseContinue(self: Parser): Node
proc parseFunction(self: Parser): Node
proc parseReturn(self: Parser): Node
proc parseDefer(self: Parser): Node
proc parseYield(self: Parser): Node
proc parseTag(self: Parser): Node
proc parseStruct(self: Parser): Node
proc parseVisibility(self: Parser): Node
proc parseTest(self: Parser): Node
proc parseAssert(self: Parser): Node
proc parseExpr(self: Parser): Node
proc parsePair(self: Parser): Node
proc parseComparative(self: Parser): Node
proc parseLogical(self: Parser): Node
proc parseShifting(self: Parser): Node
proc parseAdditive(self: Parser): Node
proc parseMultiplicative(self: Parser): Node
proc parseExponentiative(self: Parser): Node
proc parseRange(self: Parser): Node
proc parseFuncCall(self: Parser): Node
proc parseTagCall(self: Parser): Node
proc parseUnary(self: Parser): Node
proc parseAccessive(self: Parser): Node
proc parsePrimary(self: Parser): Node
proc parseBoolean(self: Parser): Node
proc parseNull(self: Parser): Node
proc parseNumber(self: Parser): Node
proc parseString(self: Parser): Node
proc parseArray(self: Parser): Node
proc parseMap(self: Parser): Node
proc parseTuple(self: Parser): Node

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

proc parseGroup(self: Parser): Node = 
  discard self.eat()
  let inner = self.parseNode()
  discard self.expect(RightParen)
  inner

proc parseList(self: Parser, node: Generator, endComma: bool = false): seq[Node] =
  var list: seq[Node] = @[]
  while true:
    if self.tt().isLineEnd():
      discard self.eat()
      continue

    let idx = self.idx
    try:
      list.add(self.node())
    except:
      if endComma:
        self.idx = idx
        break
      else:
        raise getCurrentException()

    if self.tt() == Comma:
      discard self.eat()
    else:
      break
  
  list

# TODO: Implement other kinds of destructuring
proc parseDestructure(self: Parser, ident: Generator): Node =
  let list = self.parseList(ident)
  Node(
    kind: ListDestructure,
    left: list[0].left.clone(),
    right: list[^1].right.clone(),
    listIdens: list,
  )

proc parseRawString(self: Parser): Node = 
  let open = self.expect(DoubleQuote)
  let str = self.expect(String)
  let close = self.expect(DoubleQuote)
  Node(kind: RawString, left: open.left.clone(), right: close.right.clone(), rawVal: str.val)

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
  let (annot, right) = 
    if self.tt() == Colon:
      discard self.eat()
      let typ = self.parseType()
      (some(typ), typ.right.clone())
    else:
      (none(Node), iden.right.clone())
  
  Node(kind: TypedIdent, left: iden.left.clone(), right: right, iden: iden, annot: annot)

proc parseBinaryOp(self: Parser, catagory: openArray[TokenType], next: Generator): Node =
  var lhs = self.parseNode(some(next))
  while self.tt() in catagory:
    let tok = self.eat()
    let rhs = self.parseNode(some(next))

    lhs = Node(
      kind: BinaryOp, 
      left: lhs.left.clone(), 
      right: rhs.right.clone(), 
      lhs: lhs, 
      rhs: rhs, 
      binOp: tok.typ
    )
  
  lhs

proc parseParam(self: Parser): Node =
  let idens = self.parseList(parseIdent)
  discard self.expect(Colon)
  let annot = self.parseType()
  let (default, right) = 
    if self.tt() == Assign:
      discard self.eat()
      let val = self.parseExpr()
      (some(val), val.right.clone())
    else:
      (none(Node), annot.right.clone())
  
  Node(
    kind: Param,
    left: idens[0].left.clone(),
    right: right,
    parIdens: idens,
    parAnnot: annot,
    parDefault: default,
  )

proc parseFuncBody(self: Parser): Node = 
  let start = self.expect(LeftParen)
  let params = 
    if self.tt() == RightParen:
      @[]
    else:
      self.parseList(parseParam)
  discard self.expect(RightParen)
  let ret = 
    if self.tt() == Colon:
      discard self.eat()
      some(self.parseType())
    else:
      none(Node)
  let body = self.parseBlock()

  Node(
    kind: FuncBody,
    left: start.left.clone(),
    right: body.right.clone(),
    params: params,
    error: none(Node),
    ret: ret,
    body: body,
  )

proc parseField(self: Parser): Node =
  let idens = self.parseList(parseIdent)
  discard self.expect(Colon)
  let annot = self.parseType()
  let (default, right) = 
    if self.tt() == Assign:
      discard self.eat()
      let val = self.parseExpr()
      (some(val), val.right.clone())
    else:
      (none(Node), annot.right.clone())
  
  Node(
    kind: Field,
    left: idens[0].left.clone(),
    right: right,
    fieldIdens: idens,
    fieldAnnot: annot,
    fieldDefault: default,
  )

proc parseQuotive(self: Parser): Node =
  let tok = self.eat()
  if self.tt() == Character:
    let ch = self.eat().val
    let endq = self.expect(Quote)
    Node(kind: Char, left: tok.left.clone(), right: endq.right.clone(), charVal: ch.toRunes()[0])
  else:
    let label = self.parseIdent()
    Node(kind: Label, left: tok.left.clone(), right: label.right.clone(), label: label)

proc parseAssign(self: Parser): Node = 
  let idens = self.parseDestructure(parseIdent)
  let oper = if self.tt() in BinaryOperators: some(self.eat().typ) else: none(TokenType)
  discard self.expect(Assign)
  let vals = self.parseList(gen(parseNode))
  Node(
    kind: Assign,
    left: idens.left.clone(),
    right: vals[^1].right.clone(),
    assIdens: idens,
    assOp: oper,
    assVals: vals,
  )

# Statements begin the cacade, with keyword-starting statements like 'if' and 'func'
proc parseStmt(self: Parser): Node =
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
      of Function: self.parseFunction()
      of Return: self.parseReturn()
      of Defer: self.parseDefer()
      of Yield: self.parseYield()
      of Tag: self.parseTag()
      of Structure: self.parseStruct()
      # TODO: Implement class and all its subnodes
      # TODO: Implement enum
      # TODO: Implement generic contraints
      # TODO: Write all the todos for the rest of the statements :P
      of Public, Inner, Private: self.parseVisibility()
      of Test: self.parseTest()
      of Assert: self.parseAssert()
      else: self.attempt(parseAssign, parseLookahead)
  )

proc parseDecl(self: Parser): Node =
  let kind = self.eat()
  let idens = self.parseDestructure(parseTypedIdent)

  discard self.expect(Assign)
  let vals = self.parseList(gen(parseNode))
  Node(
    kind: Decl, 
    left: kind.left.clone(), 
    right: vals[^1].right.clone(), 
    decKind: mapDecl(kind.typ),
    decIdens: idens, 
    decVals: vals,
  )

proc parseIfStmt(self: Parser): Node =
  let left = self.start()
  let test = self.parseExpr()
  let body = self.parseBlock()
  
  let (right, alt) = 
    if self.tt() == Else:
      let left = self.start()
      let alt = if self.tt() == If: self.parseIfStmt() else: self.parseBlock()
      alt.left = left
      (alt.right.clone(), some(alt))
    else:
      (body.right.clone(), none(Node))

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

  let (label, arg, right) = 
    if self.tt().isLineEnd():
      (none(Node), none(Node), start.right.clone())
    elif self.tt() == Quote:
      let first = self.parseQuotive()
      if first.kind == Label:
        if self.tt().isLineEnd():
          (some(first), none(Node), first.right.clone())
        else:
          let second = self.parseNode()
          (some(first), some(second), second.right.clone())
      else:
        (none(Node), some(first), first.right.clone())
    else:
      let first = self.parseNode()
      (none(Node), some(first), first.right.clone())

  Node(kind: Break, left: start.left.clone(), right: right, breakLabel: label, breakArg: arg)

proc parseContinue(self: Parser): Node =
  # TODO: Add continue statement to label
  let tok = self.eat()
  Node(kind: Continue, left: tok.left.clone(), right: tok.right.clone())

proc parseFunction(self: Parser): Node =
  let left = self.start()
  let name = 
    if self.tt() == Identifier:
      some(self.parseIdent())
    else:
      none(Node)
  let body = self.parseFuncBody()

  Node(
    kind: Function,
    left: left,
    right: body.right.clone(),
    fnName: name,
    fnBody: body,
  )

proc parseReturn(self: Parser): Node =
  let tok = self.eat()
  let (val, right) = 
    if self.tt().isLineEnd(): 
      (none(Node), tok.right.clone())
    else: 
      let node = self.parseNode()
      (some(node), node.right.clone())

  Node(kind: Return, left: tok.left.clone(), right: right, retVal: val)

proc parseDefer(self: Parser): Node =
  let left = self.start()
  let body = self.parseNode()
  Node(kind: Defer, left: left, right: body.right.clone(), deferred: body)

proc parseYield(self: Parser): Node =
  let left = self.start()
  let val = self.parseNode()
  Node(kind: Yield, left: left, right: val.right.clone(), yieldVal: val)

proc parseTag(self: Parser): Node =
  let left = self.start()
  let name = self.parseIdent()
  let body = self.parseFuncBody()
  Node(
    kind: Tag,
    left: left,
    right: body.right.clone(),
    tagName: name,
    tagBody: body,
  )

proc parseStruct(self: Parser): Node =
  let left = self.start()
  let name = self.parseIdent()
  discard self.expect(LeftBrace)
  let fields = self.parseList(parseField, true)
  while self.tt().isLineSeperator():
    discard self.eat()

  let close = self.expect(RightBrace)
  
  Node(
    kind: Struct,
    left: left,
    right: close.right.clone(),
    strName: name,
    strFields: fields,
  )

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

proc parseTest(self: Parser): Node =
  let left = self.start()
  let name = self.parseRawString()
  let body = self.parseBlock()
  Node(
    kind: Test,
    left: left,
    right: body.right.clone(),
    testName: name,
    testBody: body,
  )

proc parseAssert(self: Parser): Node =
  let left = self.start()
  let claim = self.parseExpr()
  Node(kind: Assert, left: left, right: claim.right.clone(), claim: claim)

proc parseLookahead(self: Parser): Node =
  # Anything that can be a statement or expression
  if self.pattern([Quote, Identifier, Colon]):
    let left = self.start()
    let label = self.parseIdent()
    discard self.eat()

    while self.tt().isLineSeperator():
      discard self.eat()

    let labeled = self.parseNode()
    return Node(
      kind: ControlLabel,
      left: left,
      right: labeled.right.clone(),
      ctrlLabel: label,
      ctrlStmt: labeled,
    )
  
  self.panic(self.at(), fmt"Expected a statement, got {self.tt()} instead", true)
  Node()

# Expressions cascade
proc parseExpr(self: Parser): Node =
  self.parsePair()

proc parsePair(self: Parser): Node = 
  let left = self.parseComparative()
  if self.tt() == Colon:
    discard self.eat()
    let right = self.parseComparative()
    return Node(
      kind: Pair, 
      left: left.left.clone(), 
      right: right.right.clone(), 
      pairKey: left, 
      pairVal: right
    )
    
  left

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
  let left = self.parseTagCall()
  if self.tt() == LeftParen:
    discard self.eat()
    let args = self.parseList(gen(parseNode))
    let right = self.expect(RightParen).right.clone()
    return Node(
      kind: FuncCall,
      left: left.left.clone(),
      right: right,
      fnCallee: left,
      fnArgs: args,
    )
  left

proc parseTagCall(self: Parser): Node = 
  let left = self.parseUnary()
  let arg = case self.tt():
    # TODO: Add Quote/char
    of DoubleQuote: self.parseString()
    of LeftBracket: self.parseArray()
    # TODO: Add LeftBrace/map
    else: return left
  
  Node(
    kind: TagCall,
    left: left.left.clone(),
    right: arg.right.clone(),
    tagCallee: left,
    tagArg: arg,
  )

proc parseUnary(self: Parser): Node =
  if self.tt() in Prefixing:
    let op = self.eat()
    let arg = self.parseNode(gen(parseAccessive))
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
  return (
    case tok.typ:
      of Boolean: self.parseBoolean()
      of Null: self.parseNull()
      of Number: self.parseNumber()
      of DoubleQuote: self.parseString()
      of Quote: self.parseQuotive()
      of Identifier: self.parseIdent()
      of LeftParen: self.attempt(parseTuple, parseGroup)
      of LeftBracket: self.parseArray()
      else: 
        self.panic(tok, fmt"Expected an expression, got {self.tt()} instead", true)
        Node() # Return something, even if an error will immediately be raised
  )

proc parseBoolean(self: Parser): Node =
  let tok = self.expect(Boolean)
  Node(kind: Bool, left: tok.left.clone(), right: tok.right.clone(), boolVal: tok.val == "true") 

proc parseNull(self: Parser): Node =
  let tok = self.expect(Null)
  Node(kind: Null, left: tok.left.clone(), right: tok.right.clone())

proc parseNumber(self: Parser): Node =
  # TODO: Use far better numerical parser
  let tok = self.expect(Number)
  Node(kind: Number, left: tok.left.clone(), right: tok.right.clone(), numVal: tok.val.parseFloat())

proc parseString(self: Parser): Node = 
  let tok = self.eat()
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
  
  Node(kind: String, left: tok.left.clone(), right: right, strElems: elems)

proc parseArray(self: Parser): Node = 
  let left = self.start()
  let items = self.parseList(gen(parseNode), true)
  let close = self.expect(RightBracket)
  Node(
    kind: Array,
    left: left,
    right: close.right.clone(),
    arrList: items,
  )

proc parseMap(self: Parser): Node =
  todo("map")

proc parseTuple(self: Parser): Node =
  let left = self.start()
  let items = self.parseList(gen(parseNode))
  let close = self.expect(RightParen)
  Node(
    kind: Tuple,
    left: left,
    right: close.right.clone(),
    tupList: items,
  )

# A large cascade of parsing
proc parseNode(self: Parser, fallback: Option[Generator] = none(Generator)): Node =
  try:
    self.parseStmt()
  except:
    let e = cast[AquaError](getCurrentException())
    if e.fallback:
      if fallback.isNone():
        self.parseExpr()
      else:
        let next = fallback.unsafeGet()
        self.next()
    else:
      raise e

# TODO: Change to return a Program object rather than just a seq[Node]
proc parse*(self: Parser): seq[Node] =
  var nodes: seq[Node] = @[]
  while self.idx <= self.tokens.len() - 1 and self.tt() != Eof:
    if self.ignore(): 
      continue

    nodes.add(self.parseNode())
    discard self.expect([NewLine, Semicolon], canTerminate=true)

  nodes

proc newParser*(tokens: seq[Token], gen: ErrorGenerator): Parser =
  Parser(errgen: gen, tokens: tokens, idx: 0)