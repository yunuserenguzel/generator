class Map

  attr_accessor :cells,:rows,:cols

  def initialize(rows=nil,cols=nil,disabled_cells=[])
    self.cells = []
    if rows
      self.rows = rows
      self.cols = cols
      rows.times do |x|
        row_cells = []
        cols.times do |y|
          cell = Cell.new(Point.new(x,y),CellType.active)
          disabled_cells.each do |point|
            if cell.point == point
              cell.cell_type = CellType.disabled
            end
          end
          row_cells << cell
        end
        self.cells << row_cells
      end
    end
  end

  def self.generate_maps(count=1, size=8, disabled_count=5)
    maps = []
    trial = 0
    while maps.count < count
      trial += 1
      map = generate_map(size, size, disabled_count)
      # puts 'Loading map'
      if map.has_solution?
        maps << map
        File.open("maps/#{map.file_name}",'w') do |f|
          f.write(maps.to_json)
        end
        puts 'Maps folder is updated'
      end
      STDOUT.write "\rMaps Tried #{trial}"
    end
    return maps
  end

  def file_name
    "c#{cols}r#{rows}-#{Time.now.to_i}.json"
  end

  def self.generate_map(rows=6,cols=6,max_disabled_count=5)
    map = Map.new
    map.cols = cols
    map.rows = rows
    cell_count = 0
    rows.times do |y|
      cells = []
      cols.times do |x|
        cell = Cell.new(Point.new(x,y),CellType.active)
        if max_disabled_count > 0 && rand(map.cols * map.rows - cell_count) < max_disabled_count
          can_disable = true
          Direction.all.each do |direction|
            neighbour_cell = map.cell_next_to cell, direction
            if neighbour_cell.is_a?(Cell) && map.cell_neighbours_count(neighbour_cell) < 3
              can_disable = false
            end
          end
          if can_disable
            cell.cell_type = CellType.disabled
            max_disabled_count -= 1
          end
        end
        cell_count += 1
        cells << cell
      end
      map.cells << cells
    end
    return map
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

  def has_solution?(cell = nil)
    # find an active cell to start
    if cell == nil
      cells.shuffle.each do |row|
        row.shuffle.each do |cell|
          @first_cell = cell.to_s
          return has_solution?(cell) if cell.cell_type == CellType.active
        end
      end
      return false
    end

    #   try to connect another cell from a direction
    #   if connects move to that direction and call solve map with that cell
    #   if solve returns false disconnect connection and try another connection
    #   if cannot move any direction return false
    [Direction.south, Direction.north, Direction.east, Direction.west].shuffle.each do |direction|
      other_cell = cell_next_to cell, direction
      if cell.connect_to(other_cell)
        puts "#{@first_cell} #{direction}: #{other_cell} \n#{self}"
        if other_cell.can_connect?
          if has_solution? other_cell
            return true
          else
            cell.disconnect_from other_cell
          end
        else
          if solved?
            return true
          else
            cell.disconnect_from other_cell
          end
        end
      end
    end
    return false
  end

  def solved?
    cells.each do |row|
      row.each do |cell|
        if cell.can_connect?
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
  end

  def cell_at(row,col)
    if row >= 0 && col >= 0 && row < cells.count && col < cells[row].count
      return cells[row][col]
    end
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

  def to_json(options = {})
    {
      rows: rows,
      cols: cols,
      cells: cells.to_json
    }.to_json
  end

  def to_s
    array = []
    cells.each.with_index do |row, row_index|
      array[row_index*3] = []
      array[row_index*3+1] = []
      array[row_index*3+2] = []
      row.each.with_index do |cell, cell_index|
        if cell.cell_type == CellType.active
          fill_array_with(array, row_index, cell_index, '0')
          array[row_index*3+1][cell_index*3+1] = '+' if cell.connection_count > 0
          array[row_index*3][cell_index*3+1] = '+' if cell.north.is_a?(Cell)
          array[row_index*3+1][cell_index*3] = '+' if cell.west.is_a? Cell
          array[row_index*3+1][cell_index*3+2] = '+' if cell.east.is_a? Cell
          array[row_index*3+2][cell_index*3+1] = '+' if cell.south.is_a? Cell
        elsif cell.cell_type == CellType.disabled
          fill_array_with(array, row_index, cell_index, '#')
        else
        end
      end
    end
    result = ''
    array.each.with_index do |row, row_index|
      result += (0..row.count).reduce("\n"){|k,v| k + '-' } if row_index %3 == 0
      result += "\n"
      row.each.with_index do |cell,cell_index|
        result += "|" if cell_index % 3 == 0
        result += "#{cell}"
      end
    end
    sleep 0.1
    return result
  end

  def fill_array_with(array, x, y, value)
    array[x*3][y*3] = value
    array[x*3][y*3+1] = value
    array[x*3][y*3+2] = value
    array[x*3+1][y*3] = value
    array[x*3+1][y*3+1] = value
    array[x*3+1][y*3+2] = value
    array[x*3+2][y*3] = value
    array[x*3+2][y*3+1] = value
    array[x*3+2][y*3+2] = value
  end

  # def ==(other_map)
  #   return to_s == other_map.to_s
  # end

end
