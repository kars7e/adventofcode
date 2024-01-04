example = false
$steps = 64
$steps_2 = 26501365
$steps = 6 if example
$steps_2 = 5000 if example

file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

$lines = File.readlines(INPUT_FILE).map { |row| row.strip.split('') }
$board = nil
$cycle = 131

class Board
  attr_reader :board, :cycle_start, :cycle_steps, :start_block, :width, :height
  attr_accessor :allow_infinite

  def reached?(x, y)
    @reached[[x, y]]
  end

  def reach(x, y)
    @reached[[x, y]] = true
  end

  def reset
    @reached = {}
    @memo = {}
  end

  def reached
    @reached.keys
  end

  def initialize
    @board = []
    @height = $lines.length
    $lines.reverse.each_with_index do |row, y|
      @width = row.length
      row.each_with_index do |value, x|
        @board[x] = []
        @board[x][y] = value
        @start_block = [x, y] if value == 'S'
      end
    end
    @reached = {}
    @memo = {}
    @steps_memo = {}
    @allow_infinite = false
    @reached = [[start_block, true]].to_h
    @step_bfs = 0
  end

  def to_s
    (0...@height).to_a.reverse.map do |y|
      (0...@width).map do |x|
        $board[x, y].reached? ? 'O' : $board[x, y].value
      end.join
    end.join("\n")
  end

  def reached
    @reached.keys
  end

  def neighbours(x, y)
    [[1, 0], [-1, 0], [0, 1], [0, -1]].map { |dx, dy| [x + dx, y + dy] }.select { |xx, yy| self.[](xx, yy) == '.' }
  end

  def walk(steps)
    walk_bfs(steps)
  end

  def walk_bfs(steps)
    until @step_bfs == steps
      visited = {}
      @step_bfs += 1

      @reached.each do |key, _|
        neighbours(*key).reject { |neigh| visited.has_key?(neigh) || @reached.has_key?(neigh) }.each do |neigh|
          visited[neigh] = true
        end
      end
      @reached = visited
    end

    @reached.keys.size
  end

  def steps_after(steps)
    samples = []
    starter = steps % $cycle
    [starter, starter + $cycle, starter + 2 * $cycle].each do |to_walk|
      walk(to_walk)
      samples << reached.size
    end
    puts samples.inspect
    c = samples[0]
    b = (4 * samples[1] - 3 * c - samples[2])
    a = samples[1] - b - c

    a * steps ** 2 + b * steps + c
  end

  def [](x, y)
    @board[x % @width][y % @height]
  end
end

$board = Board.new

# puts $board.walk(64)
puts $board.steps_after($steps_2)

