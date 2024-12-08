require 'set'
require 'benchmark'
INPUT_FILE = __dir__ + "/input.txt"
$matrix = File.readlines(INPUT_FILE).map { |row| row.strip.split('') }
$board = nil
$height, $width = $matrix.length, $matrix[0].length

class Tile
  attr_reader :x, :y, :char

  def initialize(x, y, char)
    @x, @y = x, y
    @char = char
  end

  def tile_on(direction)
    $board[@x + direction[0], @y + direction[1]]
  end
end

class Board
  attr_reader :board, :antennas

  def initialize
    @board = []
    @antennas = Hash.new { |h, k| h[k] = [] }
    $matrix.reverse.each_with_index do |row, y|
      row.each_with_index do |char, x|
        @board[x] ||= []
        @board[x][y] = Tile.new(x, y, char)
        @antennas[char] << @board[x][y] if char.match?(/[A-Za-z0-9]/)
      end
    end
  end

  def [](x, y)
    return nil if x < 0 || y < 0 || x >= $width || y >= $height
    @board[x][y]
  end

  def line_equation(node1, node2)
    lambda do |x|
      slope = (node2.y - node1.y).to_f / (node2.x - node1.x)
      node1.y + slope * (x - node1.x)
    end
  end

  def dist(node1, node2)
    (node1.x - node2.x).abs + (node1.y - node2.y).abs
  end

  def check_distance(node1, node2, candidate)
    dis = dist(node1, node2)
    dist(node1, candidate) == dis && dist(node2, candidate) == 2 * dis ||
      dist(node2, candidate) == dis && dist(node1, candidate) == 2 * dis
  end

  def find_antinodes(distance_cond = false)
    antinodes = Set.new
    antennas.each do |_, nodes|
      nodes.combination(2).each do |node1, node2|
        f = line_equation(node1, node2)
        (0...$width).each do |x|
          y = f.call(x)
          next if y < 0 || y >= $height || y % 1 != 0
          candidate = self[x, y]
          if distance_cond
            antinodes << self[x, y] if check_distance(node1, node2, candidate)
          else
            antinodes << self[x, y] if self[x, y]
          end
        end
      end
    end
    antinodes.size
  end
end

$board = Board.new
puts $board.find_antinodes(true)
puts $board.find_antinodes(false)