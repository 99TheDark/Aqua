import node

type 
  List*[T = Node] = ref object of Node
    items*: seq[T]