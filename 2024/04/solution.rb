INPUT_FILE = __dir__ + "/input.txt"
$matrix = File.readlines(INPUT_FILE).map { |row| row.strip.split('') }
$board = nil
$height, $width = $matrix.length, $matrix[0].length

class Tile
  attr_reader :x, :y, :letter

  def initialize(x, y, letter)
    @x, @y = x, y
    @letter = letter
  end

  def word(direction, length)
    return letter if length == 1
    return letter if tile_on(direction).nil?
    letter + tile_on(direction).word(direction, length - 1)
  end

  def is_x?
    diagonal_words.all? { |word| %w[MAS SAM].include?(word) }
  end

  def diagonal_words
    [tile_on([1, 1]).to_s + letter + tile_on([-1, -1]).to_s, tile_on([-1, 1]).to_s + letter + tile_on([1, -1]).to_s]
  end

  def tile_on(direction)
    $board[@x + direction[0], @y + direction[1]]
  end

  def to_s
    letter
  end
end

class Board
  attr_reader :board

  DIRECTIONS = [-1, 0, 1].product([-1, 0, 1]) - [[0, 0]]

  def initialize
    @board = []
    $matrix.reverse.each_with_index do |row, y|
      row.each_with_index do |letter, x|
        @board[x] ||= []
        @board[x][y] = Tile.new(x, y, letter)
      end
    end
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

  def all_xmases
    count = 0
    iterate_over_board do |tile|
      next if tile.letter != 'X'
      DIRECTIONS.map do |direction|
        count += 1 if tile.word(direction, 4) == 'XMAS'
      end
    end
    count
  end

  def all_xes
    count = 0
    iterate_over_board do |tile|
      next if tile.letter != 'A'
      count += 1 if tile.is_x?
    end
    count
  end
end

$board = Board.new

puts $board.all_xmases
puts $board.all_xes