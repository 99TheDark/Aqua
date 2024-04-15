# Temporary error, to make better later
type 
  AquaError* = ref object of CatchableError

  ErrorKind* = enum 
    Reading
    Lexing
    Parsing


proc panic*(msg: string) =
  let err = AquaError()
  err.msg = msg

  raise err