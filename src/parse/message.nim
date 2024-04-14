import ../types

# Because strutils.join gives template/generic instantiation error
proc join*(arr: openArray[TokenType]): string =
  var str = ""
  for idx, item in arr:
    str &= $item
    if idx < arr.len() - 1:
      str &= ", "
  
  str