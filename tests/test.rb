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

def shouldConnect(map, r1, c1, r2, c2)
  # @type [Cell]
  cell1 = map.cell_at r1,c1
  cell2 = map.cell_at r2,c2
  expectTrue cell1.connect_to cell2
end

def testCase3
  map = Map.generate_map(5,5,0)
  shouldConnect map, 2,3, 2,4
  shouldConnect map, 2,2, 2,3
  shouldConnect map, 2,1, 2,2
  shouldConnect map, 2,0, 2,1
  shouldConnect map, 2,0, 3,0
  shouldConnect map, 3,0, 3,1
end

testCase3