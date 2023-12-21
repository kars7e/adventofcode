require 'syntax_suggest/priority_queue'
example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

$matrix = File.readlines(INPUT_FILE).map { |row| row.strip.split('').map(&:to_i) }
$board = nil
$height, $width = $matrix.length, $matrix[0].length

OPPOSITE = {
  'L' => 'R',
  'R' => 'L',
  'U' => 'D',
  'D' => 'U',
}

DIRS = {
  'R' => '>',
  'L' => '<',
  'U' => '^',
  'D' => 'v',
}

class State
  attr_reader :tile, :total_heat, :from, :steps

  def initialize(tile, total_heat, from, steps)
    @tile = tile
    @total_heat = total_heat
    @from = from
    @steps = steps
  end

  def <=>(other)
    other.total_heat + other.tile.x - other.tile.y <=> @total_heat + tile.x - tile.y
  end

  def possible_states
    states = []
    tile.neighbours.each do |neigh, dir|
      unless steps.empty?
        next if steps.count(dir) == 3
        next if steps[-1] == OPPOSITE[dir]
      end
      states << State.new(neigh, total_heat + neigh.heat, self, steps.empty? || steps[0] != dir ? dir : steps + dir)
    end
    states
    end

  def key
    @key ||= [@tile.key, @steps]
  end
end

class Block

  attr_accessor :heat
  attr_reader :x, :y

  def initialize(x, y, heat)
    @x, @y = x, y
    @heat = heat
  end

  def neighbours
    neighs = []
    neighs << [left, 'L'] if left
    neighs << [right, 'R'] if right
    neighs << [up, 'U'] if up
    neighs << [down, 'D'] if down
    neighs
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
    "Block(#{x}, #{y}, #{heat})"
  end

  def key
    @key ||= [@x, @y]
  end
end

class Board
  attr_reader :board

  def start_block
    self.[](0, $height - 1)
  end

  def end_block
    self.[]($width - 1, 0)
  end

  def initialize
    @board = []
    $matrix.reverse.each_with_index do |row, y|
      row.each_with_index do |value, x|
        @board[x] ||= []
        @board[x][y] = Block.new(x, y, value)
      end
    end
  end

  def graph
    return @graph if @graph
    @graph = {}
    @from = {}
    to_visit = SyntaxSuggest::PriorityQueue.new
    to_visit << State.new(start_block, 0, nil, 'R')
    to_visit << State.new(start_block, 0, nil, 'D')
    until to_visit.empty?
      current_state = to_visit.pop
      next if @graph.has_key?(current_state.key) && @graph[current_state.key].total_heat <= current_state.total_heat
      @graph[current_state.key] = current_state
      @from[current_state.key] = current_state.from
      current_state.possible_states.each(&to_visit.method(:<<))
    end
    @graph
  end

  def to_s
    (0...$height).to_a.reverse.map do |y|
      (0...$width).map do |x|
        self.[](x, y).heat.to_s
      end.join
    end.join("\n")
  end

  def min_path
    path = []
    current = @graph.values.select { |state| state.tile == end_block }.sort_by(&:total_heat).first
    while !current.nil? && @from.has_key?(current.key)
      path << current
      current = @from[current.key]
    end
    path.reverse
  end

  def trace
    result = min_path
    result.map.zip(result[1..]).each do |(current, after)|
      current.tile.heat = DIRS[current.tile.neighbours.find { |neigh| neigh[0] == after.tile }[1]] unless after.nil?
    end
  end

  def min_total_heat
    @graph.values.select { |state| state.tile == end_block }.map(&:total_heat).min
  end

  def [](x, y)
    return nil if x < 0 || y < 0 || x >= $width || y >= $height
    @board[x][y]
  end

end

$board = Board.new
$board.graph
puts $board.min_total_heat
