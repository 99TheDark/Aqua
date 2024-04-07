type Location* = ref object of RootObj
  idx*: int
  row*: int
  col*: int

proc emptyLoc*(): Location = Location(idx: 0, row: 0, col: 0)
