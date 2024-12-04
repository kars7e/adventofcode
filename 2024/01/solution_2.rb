INPUT_FILE = __dir__ + "/input.txt"

def is_digit?(s)
  code = s.ord
  48 <= code && code <= 57
end

firsts = []
seconds = Hash.new { |h, k| h[k] = 0 }

File.open(INPUT_FILE).each do |line|
  (first, second) = line.split('   ')
  firsts << first.to_i
  seconds[second.to_i] += 1
end

solution = firsts.map { |f| f * seconds[f] }.sum

puts solution