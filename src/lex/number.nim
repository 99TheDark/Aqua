import unicode

# Example: 0x3F == 63
const BaseNumberSymbols* = {
  2: 'b',
  4: 'q',
  8: 'o',
  16: 'x',
}

proc isNumeric*(self: Rune): bool =
  let num = cast[int](self)
  48 <= num and num <= 57
