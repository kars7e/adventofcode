INPUT_FILE = __dir__ + "/input.txt"

def convert(levels)
  levels.each_cons(2).map do |left, right|
    right - left
  end
end

def valid?(differences)
  differences.all? { |d| d.between?(1, 3) } || differences.all? { |d| d.between?(-3,-1) }
end

solution = File.open(INPUT_FILE).map do |line|
  levels = line.split(' ').map(&:to_i)
  next 1 if valid?(convert(levels))
  next 1 if (0..levels.size).map do |idx|
    valid?(convert(levels.dup.tap { |l| l.delete_at(idx) }))
  end.any?
  0
end.sum

puts solution
