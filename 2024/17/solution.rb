require 'benchmark'
INPUT_FILE = __dir__ + "/input.txt"

class Machine
  attr_accessor :program, :reg_a, :reg_b, :reg_c, :opcode_map

  def initialize(program)
    @program = program
    opcode_map
    reset
  end

  def opcode_map
    @opcode_map ||= {
      0 => method(:adv),
      1 => method(:bxl),
      2 => method(:bst),
      3 => method(:jnz),
      4 => method(:bxc),
      5 => method(:out),
      6 => method(:bdv),
      7 => method(:cdv)
    }
  end

  def reset
    @reg_a = 0
    @reg_b = 0
    @reg_c = 0
    @output = []
    @jump = nil
    @pointer = 0
  end

  def run(start)
    reset
    @reg_a = start
    while true
      if @jump
        @pointer = @jump
        @jump = nil
      end
      (opcode, operand) = @program[@pointer..@pointer + 1]
      break if opcode.nil?
      opcode_map[opcode].call(operand)
      @pointer += 2
    end
    @output
  end

  def combo(operand)
    return operand if operand.between?(0, 3)
    return @reg_a if operand == 4
    return @reg_b if operand == 5
    @reg_c if operand == 6
  end

  def adv(operand)
    @reg_a /= (2 ** combo(operand))
  end

  def bxl(operand)
    @reg_b ^= operand
  end

  def bst(operand)
    @reg_b = combo(operand) % 8
  end

  def jnz(operand)
    return if @reg_a == 0
    @jump = operand
  end

  def bxc(_)
    @reg_b ^= @reg_c
  end

  def out(operand)
    @output << combo(operand) % 8
  end

  def bdv(operand)
    @reg_b = @reg_a / (2 ** combo(operand))
  end

  def cdv(operand)
    @reg_c = @reg_a / (2 ** combo(operand))
  end
end

f = File.open(INPUT_FILE)
reg_a = f.gets.scan(/Register A: (\d+)/).flatten.map(&:to_i).first
3.times { f.gets }
program = f.gets.scan(/Program: (.+)/).flatten.first.split(',').map(&:to_i)

puts "Registers: #{reg_a}"
puts "Program: #{program.inspect}"

def routine(input)
  ((input % 8) ^ 3 ^ (input / (2 ** ((input % 8) ^ 5)))) % 8
end

def find_reverse(pos, start, program)
  return start if pos == 0
  (start * 8...(start * 8 + 8)).each do |a|
    if routine(a) == program[pos - 1]
      f = find_reverse(pos - 1, a, program)
      return f if f
    end
  end

  nil
end

def solution2_1(program)
  find(program.size, 0, program)
end

def generator(input)
  Enumerator.new do |output|
    loop do
      output << routine(input)
      input = input / 8
      break if input == 0
    end
  end
end

def simplified(input)
  generator(input).to_a
end

def solution1(program, input)
  Machine.new(program).run(input).join(',')
end

def find_reverse(pos, start, program)
  return start if pos == 0
  (start * 8...(start * 8 + 8)).each do |a|
    if routine(a) == program[pos - 1]
      f = find_reverse(pos - 1, a, program)
      return f if f
    end
  end

  nil
end

def solution2_1(program)
  find_reverse(program.size, 0, program)
end

def find(pos, program, partial = 0)
  return partial if program.size == pos + 1
  puts "trying #{partial}, #{partial.to_s(2).rjust(pos * 3, "0")} for #{pos}"
  ((partial << 3)...((partial << 3) + 8)).each do |a|

    if routine(a) == program[pos]
      f = find(pos + 1, program, a)
      return f if f
    end
  end

  nil
end

def solution2_2(program)
  find(0, program)
end



puts "Solution 1: " + solution1(program, reg_a)
puts "Solution 1a: " + simplified(reg_a).join(',')



puts "Solution 2: " + solution2_1(program).to_s
puts "Solution 2a: " + solution2_2(program).to_s