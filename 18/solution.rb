example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

class Instruction
  attr_reader :direction, :steps, :color

  def initialize(direction, steps, color)
    @direction, @steps, @color = direction, steps, color
  end
end

$instructions = File.readlines(INPUT_FILE).map { |row| Instruction.new(*row.strip.gsub(/\(|\)#/, '').split(' ')) }
$board = nil

class Tile
  attr_reader :x, :y, :value

  def initialize(x, y, value)
    @x, @y = x, y
    @value = value
    @outside
    @perimeter = false
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

  def dig
    @value = '#'
  end

  def dug?
    @value == '#'
  end

  def mark_outside
    @outside = true
  end

  def outside?
    @outside
  end

  def mark_perimeter
    @perimeter = true
  end

  def perimeter?
    @perimeter == true
  end

  def is_inside?
    crossings = 0
    perimeter_seen = nil
    tile = self
    until tile.nil? do
      return true if tile.dug? && !tile.perimeter? && crossings == 0
      return false if tile.outside? && crossings == 0
      unless tile.perimeter?
        tile = tile.up
        next

      end

      return false if tile.left.nil? || tile.right.nil?

      unless tile.left.perimeter? || tile.right.perimeter?
        tile = tile.up
        next
      end

      if tile.left.perimeter? && tile.right.perimeter?
        crossings += 1
        tile = tile.up
        next
      end


      if tile.left.perimeter?
        if perimeter_seen == 'R'
          crossings += 1
          perimeter_seen = nil
        elsif perimeter_seen == 'L'
          perimeter_seen = nil
        else
          perimeter_seen = 'L'
        end
      end

      if tile.right.perimeter?
        if perimeter_seen == 'L'
          crossings += 1
          perimeter_seen = nil
        elsif perimeter_seen == 'R'
          perimeter_seen = nil
        else
          perimeter_seen = 'R'
        end
      end

      tile = tile.up
    end

    crossings.odd?
  end

  def to_s
    "Tile(#{x}, #{y}, #{value})"
  end
end

class Board
  attr_reader :board, :width, :height, :instructions

  def initialize(instructions)
    @instructions = instructions
    setup

    @board = []
    (0...height).each do |y|
      (0...width).each do |x|
        @board[x] ||= []
        @board[x][y] = Tile.new(x, y, '.')
      end
    end
  end

  def setup
    @height = 0
    @width = 0
    min_height = 0
    min_width = 0
    max_height = 0
    max_width = 0
    cur_width = 0
    cur_height = 0
    @instructions.each do |ins|
      cur_height += ins.steps.to_i if ins.direction == 'U'
      cur_height -= ins.steps.to_i if ins.direction == 'D'
      cur_width += ins.steps.to_i if ins.direction == 'R'
      cur_width -= ins.steps.to_i if ins.direction == 'L'

      min_height = cur_height if cur_height < min_height
      min_width = cur_width if cur_width < min_width
      max_height = cur_height if cur_height > max_height
      max_width = cur_width if cur_width > max_width
    end

    @width = max_width - min_width + 1
    @height = max_height - min_height + 1

    @start_x = min_width.abs
    @start_y = min_height.abs
    [@width, @height]
  end

  def start_tile
    @board[@start_x][@start_y]
  end

  def dig_perimeter
    current = start_tile
    @instructions.each do |ins|
      ins.steps.to_i.times do
        case ins.direction
        when 'U'
          current = current.up
        when 'D'
          current = current.down
        when 'L'
          current = current.left
        when 'R'
          current = current.right
        end
        current.dig
        current.mark_perimeter
      end
    end
  end

  def [](x, y)
    return nil if x < 0 || y < 0 || x >= width || y >= height
    @board[x][y]
  end

  def tiles_inside
    counter = 0
    (0...@width).each do |x|
      (0...@height).reverse_each do |y|
        tile = self[x, y]
        counter += 1 if tile.perimeter?

        next if tile.dug? || tile.outside? || tile.perimeter?

        if tile.is_inside?
          counter += 1
          tile.dig
        else
          tile.mark_outside
        end
      end
    end
    counter
  end

  def to_s
    return 'empty' if @board.nil? || @board.empty?
    (0...height).to_a.reverse.map do |y|
      (0...width).map do |x|
        @board[x][y].value.to_s
      end.join
    end.join("\n")
  end
end

$board = Board.new($instructions)

$board.dig_perimeter
puts $board.tiles_inside

puts $board.to_s