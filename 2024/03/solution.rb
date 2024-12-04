INPUT_FILE = __dir__ + "/input.txt"

input = File.open(INPUT_FILE).read
result = input.scan(/mul\((\d+,\d+)\)/).map { |match| match[0].split(",").map(&:to_i).inject(&:*) }.sum
puts result
