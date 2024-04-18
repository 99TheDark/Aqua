import pretty
import lex/lexer, parse/parser

when isMainModule:
  var src = readFile("io/script.aq")

  # I do find it annoying that Lexer == lexer
  var aLexer = newLexer(src)
  discard aLexer.lex()
  aLexer.filter()

  print aLexer.tokens

  var aParser = newParser(aLexer.tokens)
  let ast = aParser.parse()

  # print aLexer.tokens
  print ast
