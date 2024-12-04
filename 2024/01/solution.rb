INPUT_FILE = __dir__ + "/input.txt"

firsts = []
seconds = []

File.open(INPUT_FILE).each do |line|
  (first, second) = line.split('   ')
  firsts << first.to_i
  seconds << second.to_i
end

solution = firsts.sort.zip(seconds.sort).map do |f, s|
  (f-s).abs
end.sum

puts solution