import pretty
import Lexer

var src = readFile("io/script.aq")

# I do find it annoying that Lexer == lexer
var aLexer = newLexer(src)

aLexer.lex()
aLexer.filter()

print aLexer.groupStack
print aLexer.tokens
