import node

type
  Ident* = ref object of Node
    name*: string

  Type* = ref object of Node
    iden*: Ident
    option*: bool

  List*[T = Node] = ref object of Node
    items*: seq[T]