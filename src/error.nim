import unicode

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

type 
  AquaError* = ref object of CatchableError

  ErrorGenerator* = ref object
    lines: seq[seq[Rune]]

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

proc panic*(msg: string) =
  var str = ""
  
  let err = AquaError()
  err.msg = str

  raise err