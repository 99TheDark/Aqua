import strformat, strutils

type UnimplementedError* = ref object of CatchableError

proc todo*(name: string) =
  let err = UnimplementedError()
  err.msg = fmt"{name.capitalizeAscii()}s have not been implemented yet"
  
  raise err