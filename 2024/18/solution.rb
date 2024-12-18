require 'set'
require 'benchmark'
$example = false
INPUT_FILE = __dir__ + ($example ? "/example.txt" : "/input.txt")

$bytes = []
f = File.open(INPUT_FILE)
until f.eof? do
  $bytes << f.gets.strip.split(',').map(&:to_i)
end

$board = nil
$height, $width = 70, 70
$height, $width = 6, 6 if $example

class Tile
  attr_reader :x, :y
  attr_accessor :value

  def initialize(x, y, value)
    @x, @y = x, y
    @value = value
  end

  def tile_on(direction)
    $board[@x + direction[0], @y + direction[1]]
  end
end

class Board
  attr_reader :board, :start, :end_block

  def initialize
    @board = []
    reset
    add_bytes($example ? 12 : 1024)
  end

  def reset
    @visited = nil
    (0..$width).each do |y|
      (0..$height).each do |x|
        @board[x] ||= []
        @board[x][y] = Tile.new(x, y, '.')
      end
    end
    @start = @board[0][0]
    @end_block = @board[$width][$height]
  end

  def [](x, y)
    return nil if x < 0 || y < 0 || @board[x].nil?
    @board[x][y]
  end

  def neighbours(tile)
    [[1, 0], [-1, 0], [0, 1], [0, -1]].map { |dx, dy| self.[](tile.x + dx, tile.y + dy) }.compact.select { |neigh| neigh.value == '.' }
  end

  def add_bytes(bytes)
    $bytes.take(bytes).each do |x, y|
      @board[x][y].value = '#'
    end
  end

  def graph
    return @visited if @visited
    @visited = {}
    to_visit = [[start, 0]]
    until to_visit.empty?
      current, cost = to_visit.shift
      next if @visited.has_key?(current) && @visited[current] <= cost
      @visited[current] = cost
      to_add = neighbours(current).reject { |neigh| @visited.has_key?(neigh) && @visited[neigh] <= cost + 1 }.map { |neigh| [neigh, cost + 1] }
      to_visit += to_add
    end
    @visited
  end

  def shortest_path
    graph[end_block]
  end

  def to_s
    (0..$height).to_a.map do |y|
      (0..$width).map do |x|
        if @board[x][y] == start
          'S'
        elsif @board[x][y] == end_block
          'E'
        else
          self.[](x, y).value
        end
      end.join('')
    end.join("\n")
  end

  def soonest
    left = 1024
    right = $bytes.size

    until left == right
      middle = (left + right) / 2
      puts "Trying #{middle}"
      $board.reset
      $board.add_bytes(middle)
      $board.graph
      if $board.shortest_path
        left = middle + 1
      else
        right = middle
      end
    end

    $bytes.take(left).last.map(&:to_s).join(',')
  end
end

$board = Board.new
puts Benchmark.measure {
  puts "Solution1: #{$board.shortest_path}"
}
puts Benchmark.measure {
  puts "Solution2: #{$board.soonest}"
}




