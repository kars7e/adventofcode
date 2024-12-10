require 'set'
require 'benchmark'
INPUT_FILE = __dir__ + "/input.txt"
$matrix = File.readlines(INPUT_FILE).map { |row| row.strip.split('') }
$board = nil
$height, $width = $matrix.length, $matrix[0].length

class Tile
  attr_reader :x, :y, :char

  def initialize(x, y, char)
    @x, @y = x, y
    @char = char
  end

  def is_obstacle?
    @char.eql?('#')
  end

  def tile_on(direction)
    $board[@x + direction[0], @y + direction[1]]
  end
end

class Board
  attr_reader :board, :start_tile
  UP = [0, 1]
  DIRECTIONS = [[-1, 0], [0, 1], [1, 0], [0, -1]]

  def initialize
    @board = []
    $matrix.reverse.each_with_index do |row, y|
      row.each_with_index do |char, x|
        @board[x] ||= []
        @board[x][y] = Tile.new(x, y, char)
        @start_tile = @board[x][y] if char.eql?('^')
      end
    end
  end

  def [](x, y)
    return nil if x < 0 || y < 0 || x >= $width || y >= $height
    @board[x][y]
  end

  def walk1(tile=start_tile, direction=UP, visited=Set.new, visited_with_direction=Set.new)
    while true
      if visited_with_direction.include?([tile, direction])
        return -1
      end
      visited << tile
      visited_with_direction << ([tile, direction])
      next_tile = tile.tile_on(direction)
      break if next_tile.nil?
      turn_dir = DIRECTIONS[(DIRECTIONS.index(direction) + 1) % 4]
      while next_tile.is_obstacle?
        direction = turn_dir
        next_tile = tile.tile_on(direction)
        turn_dir = DIRECTIONS[(DIRECTIONS.index(direction) + 1) % 4]
        next
      end
      tile = next_tile
    end
    visited.size
  end

  def walk2(tile=start_tile, direction=UP, visited=Set.new, visited_with_direction=Set.new, check_sub = true, obstacle = nil, would_loop = Set.new)
    while true
      if visited_with_direction.include?([tile, direction])
        return -1
      end

      visited << tile
      visited_with_direction << ([tile, direction])
      next_tile = tile.tile_on(direction)
      break if next_tile.nil?
      turn_dir = DIRECTIONS[(DIRECTIONS.index(direction) + 1) % 4]
      while next_tile.is_obstacle? || obstacle == next_tile
        direction = turn_dir
        next_tile = tile.tile_on(direction)
        turn_dir = DIRECTIONS[(DIRECTIONS.index(direction) + 1) % 4]
        next
      end
      if check_sub && !would_loop.include?(next_tile) && !visited.include?(next_tile)
        while tile.tile_on(turn_dir).is_obstacle?
          turn_dir = DIRECTIONS[(DIRECTIONS.index(turn_dir) + 1) % 4]
        end
        if walk2(tile.tile_on(turn_dir), turn_dir, visited.dup, visited_with_direction.dup, false, next_tile) == -1
          would_loop << next_tile
        end
      end
      tile = next_tile
    end
    would_loop.size
  end
end

$board = Board.new
puts puts Benchmark.measure {
puts $board.walk1
}
puts Benchmark.measure {
puts $board.walk2
}