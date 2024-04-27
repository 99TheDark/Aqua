import lex/location
import unicode, strutils

proc split[T](list: seq[T], sep: T): seq[seq[T]] =
  var parts: seq[seq[T]] = @[]
  var acc: seq[T] = @[]
  for item in list:
    if item == sep:
      parts.add(acc)
      acc.setLen(0)
    else:
      acc.add(item)
  if acc.len() > 0:
    parts.add(acc)
  parts

proc size(num: int): int =
  ($num).len()

type 
  AquaError* = ref object of CatchableError

  ErrorGenerator* = ref object
    lines: seq[seq[Rune]]
    left: Location
    right: Location

  ErrorKind* = enum 
    Reading
    Lexing
    Parsing

proc `$`*(self: ErrorGenerator): string =
  var str = "ErrorGenerator(\n  lines: @[\n"
  for line in self.lines:
    str &= "    \"" & $line & "\",\n"
  str &= "  ]\n)"
  str

proc newErrorGenerator*(code: seq[Rune]): ErrorGenerator =
  ErrorGenerator(lines: code.split(Rune(ord('\n'))))

proc panic*(self: ErrorGenerator, msg: string, left: Location, right: Location) =
  let (idx, row, col) = left.unpack()
  let (ending, endRow, _) = right.unpack()
  
  let endIdx = (
    if row == endRow:
      ending
    else:
      var sum = 0
      for curRow in self.lines[0..row]:
        sum += curRow.len() + 1

      sum - 1
  )

  let numSize = size(row + 1)

  var str = "\n"
  # TODO: Add IDs
  for i in max(row - 4, 0)..row:
    let lineNum = i + 1
    str &= $lineNum & ". " & " ".repeat(numSize - size(lineNum)) & $self.lines[i] & "\n"
  
  str &= " ".repeat(max(numSize + col + 2, 0)) & "^".repeat(max(endIdx - idx, 1)) & "\n"
  str &= msg & " (" & $(row + 1) & ":" & $(col + 1) & ")\n\n"
  str &= "ErrorType:"
  
  let err = AquaError()
  err.msg = str

  raise err