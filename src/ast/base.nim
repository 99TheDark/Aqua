import node

type
  Ident* = ref object of Node
    name*: string

  List*[T = Node] = ref object of Node
    items*: seq[T]