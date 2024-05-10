import lex/lexer, parse/parser, error
import pretty, unicode, std/times, strformat

when isMainModule:
  let start = cpuTime()

  let src = readFile("io/script.aq")
  let code = src.toRunes()

  let errgen = newErrorGenerator(code)

  # I do find it annoying that Lexer == lexer
  var aLexer = newLexer(code, errgen)
  discard aLexer.lex()
  aLexer.filter()
  
  var aParser = newParser(aLexer.tokens, errgen)
  let ast = aParser.parse()

  let diff = cpuTime() - start
  echo fmt"Ran in {diff * 1000}ms"

  # print aLexer.tokens
  print ast
