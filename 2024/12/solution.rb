require 'set'
INPUT_FILE = __dir__ + "/input.txt"
$matrix = File.readlines(INPUT_FILE).map { |row| row.strip.split('') }
$board = nil
$height, $width = $matrix.length, $matrix[0].length

class Tile
  attr_reader :x, :y, :plant
  DIRECTIONS = [[-1, 0], [0, 1], [1, 0], [0, -1]]

  def initialize(x, y, plant)
    @x, @y = x, y
    @plant = plant
  end

  def tile_on(direction)
    $board[@x + direction[0], @y + direction[1]] if $board[@x + direction[0], @y + direction[1]] && $board[@x + direction[0], @y + direction[1]].plant == @plant
  end

end

class Board
  attr_reader :board

  def initialize
    @board = []
    $matrix.reverse.each_with_index do |row, y|
      row.each_with_index do |plant, x|
        @board[x] ||= []
        @board[x][y] = Tile.new(x, y, plant)
      end
    end
  end

  def neighbours(tile)
    [[1, 0], [-1, 0], [0, 1], [0, -1]].map { |dx, dy| self.[](tile.x + dx, tile.y + dy) }.compact.select { |neigh| neigh.plant == tile.plant }
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

  def sides(garden)
    return 4 if garden.size == 1
    perim_tiles = garden.select { |tile| neighbours(tile).count < 4 }

    Tile::DIRECTIONS.map do |direction|
      perim_tiles.select { |tile| tile.tile_on(direction).nil? }
                 .group_by { |tile| direction[0] == 0 ? tile.y : tile.x }.values
                 .map { |tiles| tiles.map { |tile| direction[0] == 0 ? tile.x : tile.y }
                                     .sort
                                     .slice_when { |prev, curr| prev + 1 != curr }.to_a.size }.sum
    end.sum
  end

  def perimeter(garden)
    garden.inject(0) do |sum, tile|
      sum + (4 - neighbours(tile).count)
    end
  end

  def bfs(tile)
    to_visit = [tile]
    visited = Set.new
    until to_visit.empty?
      current = to_visit.pop
      visited << current
      neighbours(current).reject { |neigh| visited.include?(neigh) }.each do |neighbour|
        visited << neighbour
        to_visit << neighbour
      end
    end
    visited
  end

  def solution
    mapped = Set.new
    sum1 = 0
    sum2 = 0
    iterate_over_board do |tile|
      next if mapped.include?(tile)
      garden = bfs(tile)
      mapped += garden
      sum1 += garden.size * perimeter(garden)
      sum2 += garden.size * sides(garden)
    end
    [sum1, sum2]
  end
end

$board = Board.new
puts $board.solution.inspect