import node

type
  Ident* = ref object of RootObj
    name*: string

  Number* = ref object of RootObj
    val*: float

  Bool* = ref object of RootObj
    val*: bool

  String* = ref object of RootObj
    exprs*: seq[Node]

    basic*: bool
