example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

class Instruction
  attr_reader :direction, :steps

  def initialize(direction, steps)
    @direction, @steps = direction, steps
  end
end

INT_TO_DIR = {
  0 => 'R',
  1 => 'D',
  2 => 'L',
  3 => 'U',
}

$instructions = File.readlines(INPUT_FILE).map do |row|
  Instruction.new(*(row.strip.gsub(/[()#]/, '').split(' ')[2].then { |rgb| [INT_TO_DIR[rgb[5].to_i], rgb[0..4].to_i(16)] }))
end

Point = Struct.new(:x, :y) do
  def shoelace(other)
    x * other.y - y * other.x
  end
end

class Board
  attr_reader :points

  def initialize(instructions)
    @instructions = instructions
    @points = []
    verticies
  end

  def area
    points = @points + [@points.first]
    points.each_cons(2).sum { |p1, p2| p1.shoelace(p2) }.abs.fdiv(2)
  end

  def verticies
    x, y = 0, 0
    @instructions.each do |ins|
      x += ins.steps if ins.direction == 'R'
      x -= ins.steps if ins.direction == 'L'
      y -= ins.steps if ins.direction == 'U'
      y += ins.steps if ins.direction == 'D'

      @points << Point.new(x, y)
    end
  end
end

$polygon = Board.new($instructions)
puts $polygon.area + $instructions.sum(&:steps) / 2 + 1