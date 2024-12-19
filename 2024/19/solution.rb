f = File.open(__dir__ + "/input.txt")
towels = f.gets.split(',').map(&:strip)
f.gets
patterns = f.readlines.map { |line| line.strip }

def find(pattern, towels, memo = {})
  return 1 if pattern.empty?
  memo[pattern] ||= towels.map { |towel| pattern.start_with?(towel) ? find(pattern[towel.size..], towels, memo) : nil }.compact.sum
end

memo = {}
puts "solution1: " + patterns.map { |pattern| find(pattern, towels, memo) }.compact.select { |x| x > 0 }.count.to_s
puts "solution2: " + patterns.map { |pattern| find(pattern, towels, memo) }.compact.sum.to_s