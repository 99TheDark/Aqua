import node, literal, options

type 
  List*[T = Node] = ref object of Node
    items*: seq[T]

  TypedIdent* = ref object of Node
    iden*: Ident
    annot*: Option[Ident] # TODO: Also change to Type object