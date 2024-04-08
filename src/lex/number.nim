import unicode

# Example: 0x3F == 63
const BaseSymbols* = {
  'b': 2,
  'q': 4,
  'o': 8,
  'x': 16,
}

proc isNumeric*(self: Rune): bool =
  let num = cast[int](self)
  48 <= num and num <= 57

type NumericRepresentation* = enum
  Simple # Ex: 3.5, 24
  Base   # Ex: 0b011010, 0xA27E
  Scientific # Ex: 9.064134e-2
