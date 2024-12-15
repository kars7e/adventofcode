require 'set'
INPUT_FILE = __dir__ + "/input.txt"

$directions = []
$matrix = []
f = File.open(INPUT_FILE)
line = f.gets
until line.strip.empty?
  $matrix << line.strip.split('')
  line = f.gets
end

until f.eof?
  $directions += f.gets.strip.split('')
end
$board = nil
$height, $width = $matrix.length, $matrix[0].length

DIRS = {
  '>' => [1, 0],
  '<' => [-1, 0],
  '^' => [0, 1],
  'v' => [0, -1]
}

class Tile
  attr_reader :x, :y
  attr_accessor :value
  DIRECTIONS = [[-1, 0], [0, 1], [1, 0], [0, -1]]
  UPDOWN = [[0, 1], [0, -1]]
  LEFTRIGHT = [[-1, 0], [1, 0]]

  def initialize(x, y, value, box_pair = nil)
    @x, @y = x, y
    @value = value
    @box_pair = box_pair
  end

  def wall?
    @value == '#'
  end

  def rock?
    @value == 'O'
  end

  def box?
    @value == '[' || @value == ']'
  end

  def box_pair
    return tile_on([-1, 0]) if @value == ']'
    return tile_on([1, 0]) if @value == '['
    raise "not a box"
  end

  def move_box(direction, from)
    if UPDOWN.include?(direction)
      tile_on(direction).move(direction, self)
      tile_on([@value == '[' ? 1 : -1, direction[1]]).move(direction, box_pair)
      box_pair.empty
    elsif LEFTRIGHT.include?(direction)
      box_pair.tile_on(direction).move(direction, box_pair)
      box_pair.value = self.value
    end
    self.value = from.value
  end

  def move_empty(from)
    @value = from.value
    self
  end

  def move(direction, from)
    raise "cannot move" unless can_move?(direction)

    return move_empty(from) if empty?
    return move_box(direction, from) if box?
    raise "oops"
  end

  def can_move?(direction)
    return false if wall?
    return true if empty?
    return [tile_on(direction), tile_on([@value == '[' ? 1 : -1, direction[1]])].all? { |tile| tile.can_move?(direction) } if UPDOWN.include?(direction)
    return tile_on(direction).can_move?(direction) if LEFTRIGHT.include?(direction)
  end

  def rock
    @value = 'O'
  end

  def move_robot
    @value = '@'
  end

  def empty
    @value = '.'
  end

  def empty?
    @value == '.'
  end

  def tile_on(direction)
    $board[@x + direction[0], @y + direction[1]]
  end
end

class Board
  attr_reader :board, :start

  def initialize
    @board = []
    $matrix.reverse.each_with_index do |row, y|
      row.each_with_index do |value, x|
        @board[x] ||= []
        @board[x][y] = Tile.new(x, y, value)
        if value == '@'
          @start = @board[x][y]
        end
      end
    end
  end

  def [](x, y)
    return nil if @board[x].nil?
    @board[x][y]
  end

  def iterate_over_board
    (0...$width).each do |x|
      (0...$height).reverse_each do |y|
        yield self[x, y]
      end
    end
  end

  def walk
    tile = start
    $directions.map do |cur_dir|
      next_tile = tile.tile_on(DIRS[cur_dir])
      next if next_tile.wall?
      if next_tile.empty?
        next_tile.move_robot
        tile.empty
        tile = next_tile
        next
      end

      rocks = []
      while next_tile.rock?
        rocks << next_tile
        next_tile = next_tile.tile_on(DIRS[cur_dir])
      end

      next if next_tile.wall?
      next_tile.rock
      tile.empty
      tile = rocks.first
      tile.move_robot
    end
  end

  def walk2
    tile = start
    $directions.map do |cur_dir|
      # puts to_s(2)
      # puts cur_dir
      # puts
      next_tile = tile.tile_on(DIRS[cur_dir])
      next if next_tile.wall?
      if next_tile.empty?
        next_tile.move_robot
        tile.empty
        tile = next_tile
        next
      end

      begin
        next_tile.move(DIRS[cur_dir], tile)
      rescue
        puts "cannot move {cur_dir}"
        next
      end
      tile.empty
      tile = next_tile
    end
  end

  def reprocess_board
    @board = []
    $matrix.reverse.each_with_index do |row, y|
      row.each_with_index do |value, x|
        x = 2 * x
        @board[x] ||= []
        @board[x + 1] ||= []
        if value == '#' || value == '.'
          @board[x][y] = Tile.new(x, y, value)
          @board[x + 1][y] = Tile.new(x + 1, y, value)
        elsif value == 'O'
          @board[x][y] = Tile.new(x, y, '[')
          @board[x + 1][y] = Tile.new(x + 1, y, ']')
        elsif value == '@'
          @board[x][y] = Tile.new(x, y, '@')
          @start = @board[x][y]
          @board[x + 1][y] = Tile.new(x + 1, y, '.')
        else
          raise "Unknown value: #{value}"
        end

      end
    end
  end

  def to_s(factor = 1)
    (0...$height).to_a.reverse.map do |y|
      (0...$width * factor).map do |x|
        self.[](x, y).value
      end.join('')
    end.join("\n")
  end

  def solve
    walk
    $board.board.flatten.select { |tile| tile.rock? }.map { |tile| tile.x + ($height - tile.y - 1) * 100 }.sum
  end

  def solve2
    walk2
    $board.board.flatten.select { |tile| tile.value == '[' }.map { |tile| tile.x + ($height - tile.y - 1) * 100 }.sum
  end

end

$board = Board.new
puts $board.solve

$board.reprocess_board
# puts $board.to_s(2)
puts $board.solve2
puts $board.to_s(2)