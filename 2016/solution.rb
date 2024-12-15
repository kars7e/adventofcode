require 'set'
BOARD_FILE = __dir__ + "/board.txt"
INPUT_FILE = __dir__ + "/input.txt"
$matrix = File.readlines(BOARD_FILE).map { |row| row.strip.split(' ').map(&:to_i) }
$board = nil
$height, $width = $matrix.length, $matrix[0].length

$dirs = File.readlines(INPUT_FILE)
class Tile
  attr_reader :x, :y, :digit
  DIR_MAP = {
    'U' => [0, 1],
    'D' => [0, -1],
    'L' => [-1, 0],
    'R' => [1, 0]
  }

  def initialize(x, y, digit)
    @x, @y = x, y
    @digit = digit
  end

  def tile_on(direction)
    dir = DIR_MAP[direction]
    $board[@x + dir[0], @y + dir[1]]
  end
end

class Board
  attr_reader :board, :start

  def initialize
    @board = []
    $matrix.reverse.each_with_index do |row, y|
      row.each_with_index do |digit, x|
        @board[x] ||= []
        @board[x][y] = Tile.new(x, y, digit)
        if digit == 5
          @start = @board[x][y]
        end
      end
    end
  end

  def [](x, y)
    return nil if x < 0 || y < 0 || x >= $width || y >= $height
    @board[x][y]
  end


  def solution
    tile = start
    $dirs.map do |dir_row|
      $dir_row = dir_row.strip.split('').each do |direction|
        next_tile = tile.tile_on(direction)
        next if next_tile.nil?
        tile = next_tile
      end
      tile.digit
    end
  end
end

$board = Board.new
puts $board.solution.inspect