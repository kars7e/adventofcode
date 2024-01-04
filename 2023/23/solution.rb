example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

$lines = File.readlines(INPUT_FILE).map { |row| row.strip.split('') }
$board = nil

class Board
  attr_reader :board, :start_block, :end_block, :width, :height

  def initialize
    @board = []
    @height = $lines.length
    $lines.reverse.each_with_index do |row, y|
      @width = row.length
      row.each_with_index do |value, x|
        @board[x] ||= []
        @board[x][y] = value

      end
    end

    @start_block = [1, @height - 1]
    @end_block = [@width - 2, 0]
  end

  def to_s
    (0...@height).to_a.reverse.map do |y|
      (0...@width).map do |x|
        $board[x, y].reached? ? 'O' : $board[x, y].value
      end.join
    end.join("\n")
  end

  def neighbours(x, y)
    neighs = []
    neighs << [x - 1, y] if left(x, y) && !'>#'.include?(left(x, y))  && !'>^v'.include?(self.[](x, y))
    neighs << [x + 1, y] if right(x, y) && !'<#'.include?(right(x, y))  && !'<^v'.include?(self.[](x, y))
    neighs << [x, y + 1] if up(x, y) && !'v#'.include?(up(x, y)) && !'<>v'.include?(self.[](x, y))
    neighs << [x, y - 1] if down(x, y) && !'^#'.include?(down(x, y)) && !'<>^'.include?(self.[](x, y))
    neighs
  end

  def left(x, y)
    $board[x - 1, y]
  end

  def right(x, y)
    $board[x + 1, y]
  end

  def up(x, y)
    $board[x, y + 1]
  end

  def down(x, y)
    $board[x, y - 1]
  end

  def walk
    walk_dfs(@start_block)
  end

  def walk_dfs(node, memo = {}, steps = 0)
    return steps if node == @end_block
    memo[node] = true
    return neighbours(*node).reject { |neigh| neigh == node || memo[neigh] == true }.map { |neigh| walk_dfs(neigh, memo.clone, steps + 1) }.max || 0
  end

  def walk_bfs
    stack = [[@start_block, 0]]
    while stack.any?
      visited = {}

      @reached.each do |key, _|
        neighbours(*key).reject { |neigh| visited.has_key?(neigh) || @reached.has_key?(neigh) }.each do |neigh|
          visited[neigh] = true
        end
      end
      @reached = visited
    end

    @reached.keys.size
  end

  def [](x, y)
    @board[x][y] if x >= 0 && y >= 0 && x < @width && y < @height
  end

end

$board = Board.new

puts $board[*$board.start_block]
puts $board[*$board.end_block]

result = $board.walk

puts result

