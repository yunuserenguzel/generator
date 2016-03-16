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

  def self.generate_maps(count = 1, size = 8, )
    maps = []
    while maps.count < count
      map = generate_map(8,8,5)
      puts 'Loading map'
      if map.has_solution?
        maps << map
        File.open("maps/c8r8-#{Time.now.to_i}.json",'w') do |f|
          f.write(maps.to_json)
        end
        puts 'Maps file is updated'
        map.print
      end
    end
    return maps
  end

  def self.generate_map(rows=6,cols=6,max_disabled_count=5)
    map = Map.new
    map.cols = cols
    map.rows = rows
    cell_count = 0
    cols.times do |x|
      cells = []
      rows.times do |y|
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

  def has_solution2?(connections = 0)
    cells.each do |row|
      row.each do |cell|
        empty_neighbours = cell_empty_neighbours(cell)
        if empty_neighbours.count == (2 - cell.connection_count)
          empty_neighbours.each do |neighbour|
            cell.connect_to neighbour
            tracked_cells = cell.track_cells
            if tracked_cells

            end
          end
        end
      end
    end
    if solved?
      return true
    elsif cell_connections_count > connections
      return has_solution2?(cell_connections_count)
    else
      return false
    end
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

  def has_solution?(cell=nil)
    # find an active cell to start
    if cell == nil
      cells.each do |row|
        row.each do |cell|
          return has_solution?(cell) if cell.cell_type == CellType.active
        end
      end
      return false
    end

    #   try to connect a direction
    #   if connects move to that direction and call solve map with that cell
    #     if solve returns false disconnect connection and try another connection
    #   if cannot move any direction return false
    Direction.all.shuffle.each do |direction|
      other_cell = cell_next_to cell, direction
      if cell.connect_to other_cell
        if solved?
          return true
        elsif has_solution? other_cell
          return true
        else
          cell.disconnect_from other_cell
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

  def cell_at(x,y)
    if x >= 0 && y >= 0 && x < cells.count && y < cells[x].count
      return cells[x][y]
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
    result = ''
    cells.each do |row|
      row.each do |cell|
        if cell.cell_type == CellType.active
          result += 'O'
        elsif cell.cell_type == CellType.disabled
          result += 'X'
        else
          result += '-'
        end
      end
      result += "\n"
    end
    return result
  end
  # def ==(other_map)
  #   return to_s == other_map.to_s
  # end

end
