import node, options

type 
  TypedIdent* = ref object of Node
    iden*: Ident
    annot*: Option[Ident] # TODO: Also change to Type object