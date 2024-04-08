import unicode

# Example: 0x3F == 63
const BaseNumberSymbols* = {
  2: 'b',
  4: 'q',
  8: 'o',
  16: 'x',
}

proc numericStart*(r: Rune): bool =
  if r == Rune('.'):
    return true

  let num = cast[int](r)
  return 48 <= num and num <= 57
