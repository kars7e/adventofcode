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
  attr_accessor :total_heat

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
    @shape = shape_from_dirs
  end

  def shape_from_dirs
    ALLOWED_DIRS.map { |k, v| [v.sort, k] }.to_h[directions.sort]
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

  def is_inside?(inside, outside, graph)
    crossings = 0
    turn_seen = nil
    tile = self
    until tile.nil?
      return true if inside.has_key?(tile) && crossings == 0
      return false if outside.has_key?(tile) && crossings == 0

      if graph.has_key?(tile)
        case tile.shape
        when '-'
          crossings += 1
        when 'J'
          if turn_seen == 'F'
            crossings += 1
            turn_seen = nil
          else
            turn_seen = tile.shape
          end
        when 'F'
          if turn_seen == 'J'
            crossings += 1
            turn_seen = nil
          elsif turn_seen == 'L'
            turn_seen = nil
          else
            turn_seen = tile.shape
          end
        when '7'
          if turn_seen == 'L'
            crossings += 1
            turn_seen = nil
          elsif turn_seen == 'J'
            turn_seen = nil
          else
            turn_seen = tile.shape
          end
        when 'L'
          if turn_seen == '7'
            crossings += 1
            turn_seen = nil
          else
            turn_seen = tile.shape
          end
        end
      end
      tile = tile.up
    end
    crossings.odd?
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
    @graph = {}
    start_tile.init_start
    to_visit = [start_tile]
    until to_visit.empty?
      visiting = to_visit.shift
      @graph[visiting] = true
      visiting.neighbours
              .select { |neigh| neigh.total_heat < 0 || neigh.total_heat > visiting.total_heat + 1 }
              .each { |neigh| neigh.distance = visiting.total_heat + 1; to_visit << neigh }
    end
    @graph
  end

  def max_distance
    graph.keys.max_by(&:total_heat).total_heat
  end

  def [](x, y)
    return nil if x < 0 || y < 0 || x >= $width || y >= $height
    @board[x][y]
  end

  def tiles_inside
    inside = {}
    outside = {}
    (0...$width).each do |x|
      (0...$height).reverse_each do |y|
        tile = self[x, y]
        next if graph.has_key?(tile)
        if tile.is_inside?(inside, outside, graph)
          inside[tile] = true
        else
          outside[tile] = true
        end
      end
    end
    inside.keys
  end


end

$board = Board.new

puts $board.max_distance
puts $board.tiles_inside.count