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

    @paths_map = Hash.new { |h, k| h[k] = [] }
    @crossings = []
    @crossings_neighs = {}
  end

  def paint!(x, y)
    @board[x][y] = 'O'
  end

  def to_s
    (0...@height).to_a.reverse.map do |y|
      (0...@width).map do |x|
        $board[x, y]
      end.join
    end.join("\n")
  end

  def neighbours(x, y)
    neighs = []
    neighs << [x - 1, y] if left(x, y) && !'#'.include?(left(x, y))
    neighs << [x + 1, y] if right(x, y) && !'#'.include?(right(x, y))
    neighs << [x, y + 1] if up(x, y) && !'#'.include?(up(x, y))
    neighs << [x, y - 1] if down(x, y) && !'#'.include?(down(x, y))
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
    # walk_bfs_squeezed
    #walk_dfs_squeezed(@start_block)
    # walk_dfs_squeezed(@start_block)
    walk_dfs_opti(@start_block, 0, @end_block, steps = 0)
  end

  def crossings
    @crossings << start_block
    @crossings_neighs[start_block] = neighbours(*start_block)

    @board.each_with_index do |row, x|
      row.each_with_index do |value, y|
        if value != '#' && neighbours(x, y).count > 2
          @crossings << [x, y]
          @crossings_neighs[[x, y]] = neighbours(x, y)
        end
      end
    end

    @crossings << end_block
    @crossings_neighs[end_block] = neighbours(*end_block)
    @crossings_ints = @crossings.map.with_index(1) { |elem, idx| [elem, idx] }.to_h
  end

  def squeeze_paths
    @crossings.each do |crossing|
      @crossings_neighs[crossing].each do |current|
        previous = crossing
        count = 1
        until @crossings_neighs[current]
          new = neighbours(*current).reject { |neigh| neigh == previous }[0]
          count += 1
          previous = current
          current = new
        end
        @paths_map[@crossings_ints[crossing]] << [@crossings_ints[current], count]
      end
    end

    from_start = @crossings_ints[@start_block]
    (to_start , to_start_cost) = @paths_map[from_start][0]
    @paths_map.delete(from_start)
    @start_block = to_start
    @paths_map[@start_block] = @paths_map[@start_block].reject { |to, _| to == from_start }.map { |to, cost| [to, cost + to_start_cost] }

    endb = @crossings_ints[@end_block]
    (to_end , to_end_cost) = @paths_map[endb][0]
    @paths_map.delete(endb)
    @end_block = to_end
    @paths_map.delete(@end_block)
    @paths_map.select {|k, v| v.any? { |to, _| to == @end_block } }.each do |k, v|
      @paths_map[k] = v.map { |to, cost| to == @end_block ? [to, cost + to_end_cost] : [to, cost]}
    end
  end

  def walk_dfs_opti(node, path_mask, end_node, steps = 0)
    return steps if node == end_node
    path_mask |= 1 << node
    @paths_map[node].map do |to, cost|
      next if path_mask & 1 << to != 0
      walk_dfs_opti(to, path_mask, end_node, steps + cost)
    end.compact.max || 0
  end

  def walk_dfs_squeezed(node, memo = {}, steps = 0)
    return steps if node == @end_block
    memo[node] = true
    @paths_map[node].select { |path| !memo[path[0]] }.map do |to, cost|
      walk_dfs_squeezed(to, memo, steps + cost)
    end.max || 0
  end

  def [](x, y)
    @board[x][y] if x >= 0 && y >= 0 && x < @width && y < @height
  end

end

$board = Board.new
$board.crossings
$board.squeeze_paths
#$board.squeeze_paths_more
$counter = 0
# result = $board.walk
result = $board.walk
puts result.inspect

