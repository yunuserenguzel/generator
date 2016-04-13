class MapGenerator
  attr_accessor :map_size, :max_number_of_disabled_cells

  def initialize(map_size, max_number_of_disabled_cells)
    @folder_name = "maps/MapSize_#{map_size}x#{map_size}_#{Time.now.to_i}"
    Dir.mkdir @folder_name
    self.map_size = map_size
    self.max_number_of_disabled_cells = max_number_of_disabled_cells
  end

  def generate_maps
    map = Map.new(self.map_size)
    generate_maps_recursively?(map, map.cells.shuffle.first.shuffle.first)
  end

  def generate_maps_recursively?(map, cell)
    Direction.all.shuffle.each do |direction|
      other_cell = map.cell_next_to cell, direction
      if cell.connect_to(other_cell)
        other_cell_can_connect = other_cell.can_connect?
        return true if other_cell_can_connect && generate_maps_recursively?(map, other_cell)
        if !other_cell_can_connect
          unconnected_points = map.unconnected_points
          if unconnected_points.length <= max_number_of_disabled_cells
            save_map Map.new(map_size, unconnected_points)
          end
        end
        cell.disconnect_from other_cell
      end
    end
    return false
  end

  def save_map(map)
    file_path = "#{@folder_name}/#{map.file_name}.json"
    if !File.exist? file_path
      File.open(file_path,'w') do |f|
        f.write(map.to_json)
        f.close
        puts file_path
      end
    end
  end

end