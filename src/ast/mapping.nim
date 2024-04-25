import ../types, kind

proc mapDecl*(typ: TokenType): DeclKind =
  case typ:
    of Var: VarDecl
    else: LetDecl
  
proc mapVis*(typ: TokenType): VisKind =
  case typ: 
    of Public: PubVis
    of Private: PriVis
    else: InnVis