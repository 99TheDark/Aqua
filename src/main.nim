import pretty
import lex/lexer

var src = readFile("io/script.aq")

# I do find it annoying that Lexer == lexer
var aLexer = newLexer(src)

aLexer.lex()
aLexer.filter()

print aLexer.tokens
