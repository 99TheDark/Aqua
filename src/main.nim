# import pretty
import Lexer

var src = readFile("io/script.aq")

# I do find it annoying that Lexer == lexer
var aLexer = newLexer(src)

aLexer.lex()

