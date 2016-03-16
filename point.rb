class Point
  attr_accessor :x, :y
  def initialize(x,y)
    self.x = x
    self.y = y
  end
  def ==(other_point)
    x == other_point.x && y == other_point.y
  end
end