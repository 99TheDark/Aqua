import node, base, kind

type
  Number* = ref object of Node
    val*: float

  Bool* = ref object of Node
    val*: bool

  String* = ref object of Node
    exprs*: seq[Node]
    raw*: seq[string]
    elems*: seq[StringElemKind]
    basic*: bool
  
  RawString* = ref object of Node # for testing, external, filepaths, etc
    val*: bool
  
  Rune* = ref object of Node
    val*: Rune

  Null* = ref object of Node

  Array* = ref object of Node
    list*: List[Node]
  
  Tuple* = ref object of Node
    list*: List[Node]