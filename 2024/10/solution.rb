require 'set'
INPUT_FILE = __dir__ + "/input.txt"
$matrix = File.readlines(INPUT_FILE).map { |row| row.strip.split('').map(&:to_i) }
$board = nil
$height, $width = $matrix.length, $matrix[0].length

class Tile
  attr_reader :x, :y, :height
  DIRECTIONS = [[-1, 0], [0, 1], [1, 0], [0, -1]]

  def initialize(x, y, height)
    @x, @y = x, y
    @height = height
  end

  def trails
    DIRECTIONS
      .map { |dir| $board[@x + dir[0], @y + dir[1]] }
        .select { |tile| tile && tile.height == @height + 1 }
  end
end

class Board
  attr_reader :board, :heads

  def initialize
    @board = []
    @heads = []
    $matrix.reverse.each_with_index do |row, y|
      row.each_with_index do |digit, x|
        @board[x] ||= []
        @board[x][y] = Tile.new(x, y, digit)
        @heads << @board[x][y] if digit == 0
      end
    end
  end

  def [](x, y)
    return nil if x < 0 || y < 0 || x >= $width || y >= $height
    @board[x][y]
  end

  def walk(tile, memo = {})
    return memo[tile] if memo.has_key?(tile)
    return Set.new([tile]) if tile.height == 9
    return Set.new if tile.trails.empty?
    memo[tile] = tile.trails.map { |next_tile| walk(next_tile, memo) }.inject(:+)
  end

  def walk2(tile, memo = {})
    return memo[tile] if memo.has_key?(tile)
    return 1 if tile.height == 9
    return 0 if tile.trails.empty?
    memo[tile] = tile.trails.map { |next_tile| walk2(next_tile, memo) }.sum
  end

  def solution1
    heads.map { |head| walk(head).size }.sum
  end

  def solution2
    heads.map { |head| walk2(head) }.sum
  end
end

$board = Board.new
puts $board.solution1
puts $board.solution2