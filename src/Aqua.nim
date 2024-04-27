import lex/lexer, parse/parser, error
import pretty, unicode

when isMainModule:
  let src = readFile("io/script.aq")
  let code = src.toRunes()

  let errgen = newErrorGenerator(code)

  # I do find it annoying that Lexer == lexer
  var aLexer = newLexer(code, errgen)
  discard aLexer.lex()
  aLexer.filter()
  
  var aParser = newParser(aLexer.tokens, errgen)
  let ast = aParser.parse()

  # print aLexer.tokens
  print ast
