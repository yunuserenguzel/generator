require './map'
require './cell'
require './cell_type'
require './direction'
require './point'
require 'json'

Map.generate_maps(100)

def write_maps(maps,filename)
  File.open("maps/#{filename}.json",'w') do |f|
    f.write(maps.to_json)
  end
end

def func(map, starting_cell, current_cell, filename, visited_cells = [], generated_maps = [])
  Direction.all.shuffle.each do |direction|
    new_cell = map.cell_next_to current_cell, direction
    if new_cell && new_cell.cell_type == CellType.active && (!visited_cells.index(new_cell) || new_cell == starting_cell)
      if new_cell == starting_cell && visited_cells.count > 1
        new_map = Map.new(map.rows,map.cols)
        new_map.cells.each do |row|
          row.each do |cell|
            cell.cell_type = CellType.disabled
          end
        end
        visited_cells.each do |cell|
          new_map.cells[cell.point.x][cell.point.y].cell_type = CellType.active
        end
        new_map.print
        puts '----------------'
        # if new_map.has_solution?
          generated_maps << new_map
          write_maps generated_maps, filename
        # end
      else
        new_visited_cells = Array.new(visited_cells)
        new_visited_cells << new_cell
        func(map, starting_cell, new_cell, filename, new_visited_cells, generated_maps)
      end
    end
  end
end

# map = Map.new(5,5)
# puts map.to_json

# starting_cell = map.cells[0][0]
# generated_maps = []
# func(map, starting_cell, starting_cell, Time.now.to_i, [starting_cell], generated_maps)
# print generated_maps.count
# duplicates = 0
# generated_maps.each do |map1|
#   generated_maps.each do |map2|
#     if map1 != map2 && map1.to_s == map2.to_s
#       duplicates += 1
#     end
#   end
# end
# puts "duplicate count: #{duplicates}"