INPUT_FILE = __dir__ + "/input.txt"

def is_digit?(s)
  code = s.ord
  48 <= code && code <= 57
end

solution = File.open(INPUT_FILE).each.map do |line|
  digits = line.split('')
               .select { |char| is_digit?(char) }
  [digits.first, digits.last].join.to_i
end.sum

puts solution