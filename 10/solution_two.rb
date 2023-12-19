INPUT_FILE = __dir__ + "/input.txt"
$matrix = File.readlines(INPUT_FILE).map { |row| row.strip.split('') }
$board = nil
$height, $width = $matrix.length, $matrix[0].length

class Tile
  ALLOWED_DIRS = {
    '|' => %w[U D],
    '-' => %w[L R],
    'L' => %w[U R],
    'J' => %w[U L],
    '7' => %w[D L],
    'F' => %w[D R]
  }

  attr_reader :x, :y, :shape, :directions
  attr_accessor :distance

  def initialize(x, y, shape)
    @x, @y = x, y
    @shape = shape
    @distance = -1
    @directions = ALLOWED_DIRS[shape]
  end

  def init_start
    @directions = []
    @distance = 0
    @directions << 'L' if left && left.directions.include?('R')
    @directions << 'R' if right && right.directions.include?('L')
    @directions << 'U' if up && up.directions.include?('D')
    @directions << 'D' if down && down.directions.include?('U')
  end

  def neighbours
    return @neighbours if @neighbours
    @neighbours = []
    @neighbours << left if directions.include?('L')
    @neighbours << right if directions.include?('R')
    @neighbours << up if directions.include?('U')
    @neighbours << down if directions.include?('D')
    @neighbours
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
    "Tile(#{x}, #{y}, #{shape}, #{distance})"
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
        if tile == 'S'
          @start_tile = @board[x][y]
        end
      end
    end
  end

  def graph
    return @graph if @graph
    @graph = []
    start_tile.init_start
    to_visit = [start_tile]
    until to_visit.empty?
      visiting = to_visit.shift
      @graph << visiting
      neighbours = visiting.neighbours
      neighbours.each do |neigh|
        if neigh.distance < 0 || neigh.distance > (visiting.distance + 1)
          neigh.distance = visiting.distance + 1
          to_visit << neigh
          puts to_visit.inspect
        end
      end
    end
    @graph
  end

  def max_distance
    graph.max_by(&:distance).distance
  end

  def [](x, y)
    return nil if x < 0 || y < 0 || x >= $width || y >= $height
    @board[x][y]
  end
end

$board = Board.new

puts $board.max_distance

def is_inside?(point, graph)
  in_ray = graph.keys.select { |gx, gy| point[1] == gy && gx > point[0] }.sort_by { |x, _| x }.map { |x, y| $matrix[y][x] }
  return false if in_ray.empty?
  crossings = 0
  turn_seen = nil
  in_ray.each do |pipe|
    next if pipe == '-'
    if pipe == '|'
      crossings += 1
      next
    end
    if turn_seen.nil?
      turn_seen = pipe
      next
    end

    if pipe == 'J'
      if turn_seen == 'F'
        crossings += 1
        turn_seen = nil
      elsif turn_seen == 'L'
        turn_seen = nil
      else
        turn_seen = pipe
      end
    end

    if pipe == '7'
      if turn_seen == 'L'
        crossings += 1
        turn_seen = nil
      elsif turn_seen == 'F'
        turn_seen = nil
      else
        turn_seen = pipe
      end
    end

    if pipe == 'L'
      if turn_seen == '7'
        crossings += 1
        turn_seen = nil
      elsif turn_seen == 'J'
        turn_seen = nil
      end
    end

    if pipe == 'F'
      if turn_seen == 'J'
        crossings += 1
        turn_seen = nil
      elsif turn_seen == '7'
        turn_seen = nil
      end
    end
  end
  crossings.odd?
end

# graph = build_graph
#
# counter = 0
# points = 0
# all = 0
# (0...$matrix.length).each do |y|
#   (0...$matrix[0].length).each do |x|
#     all += 1
#     next if graph.has_key?([x, y])
#     points += 1
#     counter += 1 if is_inside?([x, y], graph)
#   end
# end
# puts all
# puts counter
# puts points