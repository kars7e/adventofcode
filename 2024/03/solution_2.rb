INPUT_FILE = __dir__ + "/input.txt"

input = File.open(INPUT_FILE).read
result = input
           .scan(/(mul\(\d+,\d+\)|do\(\)|don't\(\))/)
           .inject([true, 0]) do |acc, match|
  token = match[0]
  next [true, acc[1]] if token == 'do()'
  next [false, acc[1]] if token == "don't()"
  next [true, acc[1] + token.scan(/\d+,\d+/)[0].split(",").map(&:to_i).inject(&:*)] if acc[0]
  acc
end[1]
puts result
