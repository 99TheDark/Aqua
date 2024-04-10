import node, base

type
  Block* = ref object of Node
    stmts*: seq[Node]

  IfStmt* = ref object of Node
    cond*: Node
    body*: Block
    alt*: Block
  
  ForLoop* = ref object of Node
    iden*: Ident
    iter*: Node
    body*: Node
  
  WhileLoop* = ref object of Node
    cond*: Node
    body*: Block
  
  DoWhileLoop* = ref object of Node
    body*: Block
    cond*: Node
  
  Loop* = ref object of Node
    body*: Block
  
  # TODO: Add Match statement

  Break* = ref object of Node
    to*: Node 
  
  Continue* = ref object of Node