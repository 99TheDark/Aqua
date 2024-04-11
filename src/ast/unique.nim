import node, base, options

type 
  TypedIdent* = ref object of Node
    iden*: Ident
    annot*: Option[Node]