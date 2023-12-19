example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"
$matrix = File.readlines(INPUT_FILE).map { |row| row.strip.split('') }
$empty_rows = $matrix.map.with_index { |row, idx| idx if row.all? { |elem| elem == '.' } }.compact
$empty_columns = (0...$matrix[0].length).map.with_index { |column| column if $matrix.all? { |row| row[column] == '.' } }.compact
$board = nil
$height, $width = $matrix.length, $matrix[0].length

class Point
  attr_reader :x, :y, :value, :is_galaxy

  def initialize(x, y, value)
    @x, @y = x, y
    @value = value
    @is_galaxy = value == '#' ? true : false

  end

  def to_s
    "Point(#{x}, #{y}, #{value})"
  end

  def shortest_distance(point, factor)
    result = (point.x - x).abs + (point.y - y).abs
    result += $empty_columns.select { |column| column.between?(*[x, point.x].sort) }.count * (factor - 1)
    result += $empty_rows.select { |column| column.between?(*[y, point.y].sort) }.count * (factor - 1)
    result
  end
end

class Board
  attr_reader :board, :galaxies

  def initialize
    @board = []
    @galaxies = []
    $matrix.each_with_index do |row, y|
      row.each_with_index do |value, x|
        @board[x] ||= []
        @board[x][y] = Point.new(x, y, value)
        if value == '#'
          @galaxies << @board[x][y]
        end
      end
    end
  end


  def galaxy_distances(factor = 2)
    @galaxy_distances = []
    galaxies.combination(2).each do |a, b|
      @galaxy_distances << a.shortest_distance(b, factor)
    end
    @galaxy_distances
  end

  def [](x, y)
    return nil if x < 0 || y < 0 || x >= $width || y >= $height
    @board[x][y]
  end
end

$board = Board.new

puts $board.galaxy_distances.sum
puts $board.galaxy_distances(1000000).sum