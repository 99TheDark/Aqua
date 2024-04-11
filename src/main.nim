import pretty
import lex/lexer, parse/parser, types

var src = readFile("io/script.aq")

# I do find it annoying that Lexer == lexer
var aLexer = newLexer(src)
aLexer.lex()
aLexer.filter()

var aParser = newParser(aLexer.tokens)
discard aParser.parse()

print aLexer.tokens
