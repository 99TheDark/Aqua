type Location* = ref object of RootObj
  idx*: int
  row*: int
  col*: int

proc shift*(self: Location, count: int) =
  self.idx += count
  self.col += count

proc next*(self: Location) = self.shift(1)

proc emptyLoc*(): Location = Location(idx: 0, row: 0, col: 0)
