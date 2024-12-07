INPUT_FILE = __dir__ + "/input.txt"

class Integer
  def method_missing(name, *args)
    if name.eql?(:"||")
      (self.to_s + args[0].to_s).to_i
    else
      super
    end
  end
end

def solve(factors, operators, target)
  factors = factors.dup
  (left, right) = factors.shift(2)
  z = operators.map do |op|
    result = left.send(op, right)
    next false if result > target
    next result == target if factors.empty?
    solve([result] + factors, operators, target)
  end
  z.any?

end

solution1 = 0
solution2 = 0
File.open(INPUT_FILE).each do |line|
  (target, factors) = line.split(':')
  factors = factors.split(' ').compact.map(&:to_i)
  target = target.to_i
  solution1 += target if solve(factors, [:+, :*], target)
  solution2 += target if solve(factors, [:+, :"||", :*], target)

end

puts solution1
puts solution2