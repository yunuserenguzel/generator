class Map
  include ActiveModel::Serializers::JSON
  attr_accessor :cells, :size, :number_of_disabled_cells, :disabled_cells

  def initialize(size, disabled_cells = [])
    self.size = size
    self.disabled_cells = disabled_cells
    self.number_of_disabled_cells = disabled_cells.length
    self.cells = size.times.to_a.map do |y|
      size.times.to_a.map do |x|
        cell = Cell.new(Point.new(x,y))
        cell.cell_type = disabled_cells.include?(Point.new(x,y)) ? CellType.disabled : CellType.active
        cell
      end
    end
  end

  def file_name
    disabled_cells_hash = disabled_cells.map{|point| "#{point.x}#{point.y}"}.join('-')
    "D#{number_of_disabled_cells}-S#{size}x#{size}-#{disabled_cells_hash}"
  end

  def print
    puts to_s
  end

  def cell_connections_count
    total = 0
    cells.each do |row|
      row.each do |cell|
        total += cell.connection_count
      end
    end
    return total
  end

  def has_solution?
    # find an active cell to start
    cells.shuffle.each do |row|
      row.shuffle.each do |cell|
        if cell.cell_type == CellType.active
          return has_solution_helper?(cell)
        end
      end
    end
    return false
  end

# try to connect another cell from a direction
# if connects move to that direction and call solve map with that cell
# if solve returns false disconnect connection and try another connection
# if cannot move any direction return false
  def has_solution_helper?(cell)
    Direction.all.shuffle.each do |direction|
      # puts "trying for #{cell} at direction #{direction}"
      other_cell = cell_next_to cell, direction
      if cell.connect_to(other_cell)
        # puts "#{direction}: #{other_cell} \n#{self}"
        other_cell_can_connect = other_cell.can_connect?
        return true if other_cell_can_connect && has_solution_helper?(other_cell)
        return true if !other_cell_can_connect && solved?
        cell.disconnect_from other_cell
      end
    end
    return false
  end

  def unconnected_points
    cells.flat_map{ |row| row.flat_map { |cell| cell.connection_count == 0 ? cell.point : nil } }.compact
  end

  def solved?
    # puts "#{self}"
    cells.each do |row|
      row.each do |cell|
        if cell.connection_count != 2
          return false
        end
      end
    end
    return true
  end

  def cell_next_to(cell,direction)
    case direction
      when Direction.north
        return cell_at(cell.point.x,cell.point.y-1)
      when Direction.south
        return cell_at(cell.point.x,cell.point.y+1)
      when Direction.west
        return cell_at(cell.point.x-1,cell.point.y)
      when Direction.east
        return cell_at(cell.point.x+1,cell.point.y)
    end
    return nil
  end

  def cell_at(x,y)
    if x >= 0 && y >= 0 && y < cells.count && x < cells[y].count
      return cells[y][x]
    end
    # return "cell is empty: #{x}, #{y}"
  end

  def cell_neighbours_count(cell)
    total = 0
    Direction.all.each do |direction|
      neighbour_cell = cell_next_to(cell,direction)
      total += 1 if neighbour_cell && neighbour_cell.cell_type == CellType.active
    end
    return total
  end

  def cell_empty_neighbours(cell)
    empty_cells = []
    Direction.all.each do |direction|
      neighbour_cell = cell_next_to(cell,direction)
      empty_cells << neighbour_cell if neighbour_cell &&
        neighbour_cell.cell_type == CellType.active && neighbour_cell.can_connect?
      empty_cells
    end
  end

  def as_json(options = {})
    {
      size: size,
      disabled_cells: disabled_cells.as_json(options)
    }
  end

  # def to_s
  #   array = []
  #   cells.each.with_index do |row, row_index|
  #     array[row_index*3] = []
  #     array[row_index*3+1] = []
  #     array[row_index*3+2] = []
  #     row.each.with_index do |cell, cell_index|
  #       if cell.cell_type == CellType.active
  #         fill_array_with(array, row_index, cell_index, '0')
  #         array[row_index*3+1][cell_index*3+1] = '+' if cell.connection_count > 0
  #         array[row_index*3][cell_index*3+1] = '+' if cell.north.is_a?(Cell)
  #         array[row_index*3+1][cell_index*3] = '+' if cell.west.is_a? Cell
  #         array[row_index*3+1][cell_index*3+2] = '+' if cell.east.is_a? Cell
  #         array[row_index*3+2][cell_index*3+1] = '+' if cell.south.is_a? Cell
  #       elsif cell.cell_type == CellType.disabled
  #         fill_array_with(array, row_index, cell_index, '#')
  #       else
  #       end
  #     end
  #   end
  #   result = ''
  #   array.each.with_index do |row, row_index|
  #     result += (0..row.count).reduce("\n"){|k,v| k + '-' } if row_index %3 == 0
  #     result += "\n"
  #     row.each.with_index do |cell,cell_index|
  #       result += "|" if cell_index % 3 == 0
  #       result += "#{cell}"
  #     end
  #   end
  #   # sleep 0.2
  #   return result
  # end

  # def fill_array_with(array, x, y, value)
  #   array[x*3][y*3] = value
  #   array[x*3][y*3+1] = value
  #   array[x*3][y*3+2] = value
  #   array[x*3+1][y*3] = value
  #   array[x*3+1][y*3+1] = value
  #   array[x*3+1][y*3+2] = value
  #   array[x*3+2][y*3] = value
  #   array[x*3+2][y*3+1] = value
  #   array[x*3+2][y*3+2] = value
  # end

  # def ==(other_map)
  #   return to_s == other_map.to_s
  # end

end
