require 'benchmark'
INPUT_FILE = __dir__ + "/input.txt"

machines = []

f = File.open(INPUT_FILE)
until f.eof?
  (ax, ay) = f.gets.scan(/X\+(\d+).*Y\+(\d+)/).flatten.map(&:to_i)
  (bx, by) = f.gets.scan(/X\+(\d+).*Y\+(\d+)/).flatten.map(&:to_i)
  (px, py) = f.gets.scan(/X=(\d+).*Y=(\d+)/).flatten.map(&:to_i)
  f.gets
  machines << [[ax, ay], [bx, by], [px, py]]
end

def bruteforce(machine)
  a, b, p = machine
  (0..100).to_a.repeated_permutation(2).map do |i, j|
    i * 3 + j if p[0] == i * a[0] + j * b[0] && p[1] == i * a[1] + j * b[1]
  end.compact.min
end

def calculate(machine)
  ax, ay, bx, by, px, py = machine.flatten
  px, py = [px, py].map { |t| t + 10000000000000 }
  b = (ay * px - ax * py) / (ay * bx - ax * by).to_f
  a = (px - b * bx) / ax.to_f

  return 3 * a + b if a % 1 == 0 && b % 1 == 0 && a >= 0 && b >= 0
  
  nil
end

solution1 = machines.map do |machine|
  bruteforce(machine)
end.compact.sum

solution2 = machines.map do |machine|
  calculate(machine).to_i
end.compact.sum

puts solution1
puts solution2
