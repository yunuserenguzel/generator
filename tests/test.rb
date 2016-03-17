require './road'

def expectTrue(expression)
  puts "FAILED#{caller[0]}" if !expression
end

def testCase1
  c1 = Cell.new(Point.new(3, 4), CellType.active)
  c2 = Cell.new(Point.new(3, 5), CellType.active)
  c1.connect_to(c2)
  expectTrue c1.direction_of(c2) == Direction.south
  expectTrue c2.direction_of(c1) == Direction.north
end

def testCase2
  c1 = Cell.new(Point.new(4, 4), CellType.active)
  c2 = Cell.new(Point.new(3, 4), CellType.active)
  c1.connect_to(c2)
  expectTrue c1.direction_of(c2) == Direction.west
  expectTrue c2.direction_of(c1) == Direction.east
end
