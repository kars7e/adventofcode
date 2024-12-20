INPUT_FILE = __dir__ + "/input.txt"
$matrix = File.readlines(INPUT_FILE).map { |row| row.strip.split('') }
$board = nil
$height, $width = $matrix.length, $matrix[0].length

class Tile
  attr_reader :x, :y, :value
  DIRECTIONS = [[-1, 0], [0, 1], [1, 0], [0, -1]]

  def initialize(x, y, value)
    @x, @y = x, y
    @value = value
  end

  def tile_on(direction)
    $board[@x + direction[0], @y + direction[1]]
  end

  def neighs
    DIRECTIONS.map { |dx, dy| $board[x + dx, y + dy] }
  end

  def wall?
    @value == '#'
  end

end

class Board
  attr_reader :board, :start, :end_block

  def initialize
    @board = []
    $matrix.reverse.each_with_index do |row, y|
      row.each_with_index do |value, x|
        @board[x] ||= []
        @board[x][y] = Tile.new(x, y, value)
        @start = @board[x][y] if value == 'S'
        @end_block = @board[x][y] if value == 'E'
      end
    end
  end

  def neighbours(tile)
    [[1, 0], [-1, 0], [0, 1], [0, -1]].map { |dx, dy| self.[](tile.x + dx, tile.y + dy) }
  end

  def [](x, y)
    return nil if x < 0 || y < 0 || x >= $width || y >= $height
    @board[x][y]
  end

  def iterate_over_board
    (0...$width).each do |x|
      (0...$height).reverse_each do |y|
        yield self[x, y]
      end
    end
  end

  def path
    return @path if @path
    @path = {}
    to_visit = [[start, 0]]
    until to_visit.empty?
      current, cost = to_visit.shift
      next if @path.has_key?(current)
      @path[current] = cost
      to_visit += current.neighs.compact.reject { |neigh| neigh.wall? }.map { |neigh| [neigh, cost + 1] }
    end
    @path
  end

  def solution_1
    puts path[end_block]
    path.map do |tile, start_cost|
      Tile::DIRECTIONS.filter_map do |direction|
        wall_candidate = tile.tile_on(direction)
        behind_wall = wall_candidate&.tile_on(direction)
        if wall_candidate&.wall? && path.has_key?(behind_wall)
          cost = (start_cost - path[behind_wall])
          1 if cost >= 102
        end
      end.sum
    end.sum
  end

  def solution_2
    tiles = path.sort_by(&:last)
    tiles.map do |start_tile, start_cost|
      tiles[start_cost + 1..].filter_map do |end_tile, end_cost|
        distance = (end_tile.x - start_tile.x).abs + (end_tile.y - start_tile.y).abs
        1 if distance <= 20 && end_cost - start_cost - distance >= 100
      end.sum
    end.sum
  end

  def solution_2b
    path.map do |tile, start_cost|
      (-10..10).permutation(2)
    end
  end
end

$board = Board.new
puts $board.solution_1
puts $board.solution_2
