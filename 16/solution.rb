example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

$matrix = File.readlines(INPUT_FILE).map { |row| row.strip.split('') }
$board = nil
$height, $width = $matrix.length, $matrix[0].length

class Tile
  ALLOWED_DIRS = {
    '.' => { 'L' => %w[R], 'R' => %w[L], 'U' => %w[D], 'D' => %w[U] },
    '|' => { 'L' => %w[U D], 'R' => %w[U D], 'U' => %w[D], 'D' => %w[U] },
    '-' => { 'U' => %w[L R], 'D' => %w[L R], 'L' => %w[R], 'R' => %w[L] },
    '/' => { 'U' => %w[L], 'R' => %w[D], 'L' => %w[U], 'D' => %w[R] },
    '\\' => { 'U' => %w[R], 'R' => %w[U], 'L' => %w[D], 'D' => %w[L] },
  }

  attr_reader :x, :y, :shape, :directions
  attr_accessor :energized

  def initialize(x, y, shape)
    @x, @y = x, y
    @shape = shape
    @energized = false
    @directions = ALLOWED_DIRS[shape]
    @neighbours = {}
  end

  def next_steps(from)
    ALLOWED_DIRS[shape][from]
  end

  def neighbours(from)
    return @neighbours[from] if @neighbours[from]
    @neighbours[from] = []
    @neighbours[from] << [left, 'R'] if directions[from].include?('L') && left
    @neighbours[from] << [right, 'L'] if directions[from].include?('R') && right
    @neighbours[from] << [up, 'D'] if directions[from].include?('U') && up
    @neighbours[from] << [down, 'U'] if directions[from].include?('D') && down
    @neighbours[from]
  end

  def left
    $board[@x - 1, @y]
  end

  def right
    $board[@x + 1, @y]
  end

  def up
    $board[@x, @y + 1]
  end

  def down
    $board[@x, @y - 1]
  end

  def to_s
    "Tile(#{x}, #{y}, #{shape}, #{energized})"
  end
end

class Board
  attr_reader :start_tile
  attr_reader :board

  def initialize
    @board = []
    $matrix.reverse.each_with_index do |row, y|
      row.each_with_index do |tile, x|
        @board[x] ||= []
        @board[x][y] = Tile.new(x, y, tile)
      end
    end
  end

  def start_tile
    $board[0, $height - 1]
  end

  def energized_tiles
    @board.flatten.select(&:energized)
  end

  def to_s
    (0...$height).to_a.reverse.map do |y|
      (0...$width).map do |x|
        tile = self.[](x, y); tile.energized ? '#' : tile.shape
      end.join
    end.join("\n")
  end

  def [](x, y)
    return nil if x < 0 || y < 0 || x >= $width || y >= $height
    @board[x][y]
  end

  def beam(x, y, from)
    to_visit = [[self.[](x,y), from]]
    visited = {}
    until to_visit.empty?
      (current, from) = to_visit.shift
      visited[[current, from]] = true
      current.energized = true
      current.neighbours(from).each do |neighbour|
        if !visited.has_key?(neighbour) || !neighbour[0].energized
          to_visit << neighbour
        end
      end
    end
    energized_tiles
  end

end

max = 0
(0...$width).each do |x|
  $board = Board.new
  max = [max, $board.beam(x, $height - 1, 'U').count].max
  $board = Board.new
  max = [max, $board.beam(x, 0, 'D').count].max
end

(0...$height).each do |y|
  $board = Board.new
  max = [max, $board.beam(0, y, 'L').count].max
  $board = Board.new
  max = [max, $board.beam($width - 1, y, 'R').count].max
end

puts max

