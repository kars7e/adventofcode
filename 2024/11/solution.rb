require 'benchmark'
INPUT_FILE = __dir__ + "/input.txt"

input = File.open(INPUT_FILE).read.split(' ').map(&:to_i)

def split_num(num)
  return 0 if num == 0
  [num.digits.reverse[0..num.digits.size/2-1].join.to_i, num.digits.reverse[num.digits.size/2..num.digits.size-1].join.to_i]
end

memo = {}
def blink(stone, attempts, memo)
  key = [stone, attempts]
  return memo[key] if memo.has_key?(key)
  return 1 if attempts == 0
  return memo[key] = blink(1, attempts - 1, memo) if stone == 0
  return memo[key] = split_num(stone).map { |num| blink(num, attempts - 1, memo) }.sum if stone.digits.size.even?
  memo[key] = blink(stone * 2024, attempts - 1, memo)
end

solution1 = input.map { |num| blink(num, 25, memo) }.sum
solution2 = input.map { |num| blink(num, 75, memo) }.sum
puts solution1
puts solution2
