f = File.open(__dir__ + "/input.txt")
towels = f.gets.split(',').map(&:strip)
f.gets
patterns = f.readlines.map { |line| line.strip }

def find(pattern, towels, memo = {})
  return 1 if pattern.empty?
  memo[pattern] ||= towels.filter_map { |towel| find(pattern[towel.size..], towels, memo) if pattern.start_with?(towel) }.sum
end

memo = {}
puts "solution1: " + patterns.map { |pattern| find(pattern, towels, memo) }.select { |x| x > 0 }.count.to_s
puts "solution2: " + patterns.map { |pattern| find(pattern, towels, memo) }.sum.to_s