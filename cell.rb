class Cell
  attr_accessor :point,:cell_type,
                :north,:south,:west,:east

  def initialize(point=nil,cell_type=nil)
    if point.is_a?Point
      self.point = point
      self.cell_type = cell_type
    end

  end
  def connect_to(other_cell)
    if other_cell.is_a? Cell
      if can_connect? && other_cell.can_connect?
        if cell_at(direction_of(other_cell)) == nil &&
          other_cell.cell_at(other_cell.direction_of(self)) == nil
          set_cell_at direction_of(other_cell), other_cell
          other_cell.set_cell_at other_cell.direction_of(self), self
          return true
        end
      end
    end
    return false
  end

  def disconnect_from(other_cell)
    set_cell_at(direction_of(other_cell),nil)
    other_cell.set_cell_at(other_cell.direction_of(self),nil)
  end

  def set_cell_at(direction,cell)
    instance_variable_set "@#{direction}", cell
  end

  def cell_at(direction)
    method(direction).call
  end

  def direction_of(other_cell)
    if point.x == other_cell.point.x
      if point.y == other_cell.point.y + 1
        Direction.north
      elsif point.y == other_cell.point.y - 1
        Direction.south
      end
    elsif point.y == other_cell.point.y
      if point.x == other_cell.point.x + 1
        Direction.west
      elsif point.x == other_cell.point.x - 1
        Direction.east
      end
    end
  end

  def can_connect?
    connection_count < 2 && cell_type == CellType.active
  end

  def connection_count
    total = 0
    total += 1 if north.is_a? Cell
    total += 1 if south.is_a? Cell
    total += 1 if west.is_a? Cell
    total += 1 if east.is_a? Cell
    return total
  end

  def connected_cell_from(cell)
    if connection_count == 2
      Direction.all.count do |direction|
        new_cell = cell_at direction
        if new_cell != cell
          return new_cell
        end
      end
    end
  end

  def track_cells
    cell = nil
    Direction.all.each do |direction|
      cell = cell_at direction
      break if cell.is_a? Cell
    end
    cells = [self]
    previous_cell = cell
    current_cell = self
    loop do
      next_cell = current_cell.connected_cell_from(previous_cell)
      if next_cell
        if next_cell == self
          return cells
        else
          cells << next_cell
        end
      else
        return nil
      end
    end
  end

  def to_json(options = {})
    {
      x: point.x,
      y: point.y,
      cell_type: cell_type
    }.to_json
  end
end