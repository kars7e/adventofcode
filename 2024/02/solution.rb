INPUT_FILE = __dir__ + "/input.txt"

solution = File.open(INPUT_FILE).map do |line|
  levels = line.split(' ').map(&:to_i)

  previous_direction = levels[1] <=> levels[0]
  right = levels.pop
  safe = 1
  until levels.empty?
    left = levels.pop
    direction = right <=> left
    if direction == 0 || (left - right).abs > 3 || direction != previous_direction
      safe = 0
      break
    end
    previous_direction = direction
    right = left
  end
  safe
end.sum

puts solution