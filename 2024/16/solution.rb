require 'set'
require 'syntax_suggest/priority_queue'

INPUT_FILE = __dir__ + "/input.txt"
$matrix = File.readlines(INPUT_FILE).map { |row| row.strip.split('') }
$board = nil
$height, $width = $matrix.length, $matrix[0].length

class State
  attr_reader :tile, :total_points, :from

  def initialize(tile, total_points, from)
    @tile = tile
    @total_points = total_points
    @from = from
  end

  def <=>(other)
    other.total_points <=> @total_points
  end

  def possible_states
    states = []
    direction = @from.nil? ? [1,0] : [@tile.x - @from.tile.x, @tile.y - @from.tile.y]
    tile.neighs.each do |neigh, dir|
      extra_points = 1
      extra_points += 1000 if direction && dir != direction
      states << State.new(neigh, total_points + extra_points, self)
    end
    states
  end

  def key
    @key ||= [@tile.key, @from&.tile]
  end
end

class Tile
  attr_reader :x, :y, :value
  DIRECTIONS = [[-1, 0], [0, 1], [1, 0], [0, -1]]

  def initialize(x, y, value)
    @x, @y = x, y
    @value = value
  end

  def key
    @key ||= [@x, @y]
  end

  def tile_on(direction)
    $board[@x + direction[0], @y + direction[1]]
  end

  def neighs
    DIRECTIONS.map { |dx, dy| [$board[x + dx, y + dy], [dx, dy]] }.select { |neigh, _| neigh&.can_move? }
  end

  def can_move?
    @value != '#'
  end

end

class Board
  attr_reader :board, :start, :end_block

  def initialize
    @board = []
    $matrix.reverse.each_with_index do |row, y|
      row.each_with_index do |value, x|
        @board[x] ||= []
        @board[x][y] = Tile.new(x, y, value)
        @start = @board[x][y] if value == 'S'
        @end_block = @board[x][y] if value == 'E'
      end
    end
  end

  def neighbours(tile)
    [[1, 0], [-1, 0], [0, 1], [0, -1]].map { |dx, dy| self.[](tile.x + dx, tile.y + dy) }.compact.select(&:can_move?)
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

  def graph
    return @graph if @graph
    @graph = Hash.new { |h, k| h[k] = [] }
    @from = Hash.new { |h, k| h[k] = [] }
    to_visit = SyntaxSuggest::PriorityQueue.new
    to_visit << State.new(start, 0, nil)
    until to_visit.empty?
      current_state = to_visit.pop
      next if @graph.has_key?(current_state.key) && @graph[current_state.key].min_by(&:total_points).total_points < current_state.total_points
      @graph[current_state.key] << current_state
      @from[current_state.key] << current_state.from if current_state.from != nil
      current_state.possible_states.each(&to_visit.method(:<<))
    end
    @graph
  end

  def min_path
    visited = Set.new
    to_visit = @graph.values.select { |states| states.any? { |state| state.tile == end_block } }.flatten.select { |state| state.total_points == min_points }
    until to_visit.empty?
      current = to_visit.pop
      visited << current.tile
      to_visit << current.from if current.from
    end
    visited
  end

  def to_s(visited)
    (0...$height).to_a.reverse.map do |y|
      (0...$width).map do |x|
        visited.include?(self.[](x, y)) ? 'O' : self.[](x, y).value
      end.join('')
    end.join("\n")
  end

  def min_points
    @graph.values.select { |states| states.any? { |state| state.tile == end_block } }.flatten.map(&:total_points).min
  end
end

$board = Board.new
$board.graph
puts $board.min_points
puts $board.min_path.size
puts $board.to_s($board.min_path)
