import ../types

# Because strutils.join gives template/generic instantiation error
proc list*(arr: openArray[TokenType], final: string): string =
  case arr.len():
    of 0: ""
    of 1: $arr[0]
    else:
      var str = ""
      let len = arr.len()
      for idx, item in arr[0..(len - 3)]:
        str &= $item
      str &= $arr[len - 2] & " " & final & " " & $arr[len - 1]

      str