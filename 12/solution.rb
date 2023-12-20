example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

rows = File.readlines(INPUT_FILE).map{ |row| row.split(' ') }
patterns = rows.map(&:first)
sequences = rows.map(&:last).map{|sequence| sequence.split(',').map(&:to_i)}

def subproblem(pattern, sequences)
  if sequences.empty?
    return 0 if pattern && pattern.include?('#')
    return 1
  end
  return 0 if pattern.nil? || pattern.empty?
  idx = find_first_block(pattern, sequences[0])
  return 0 if idx.nil?
  remainder = pattern[idx+sequences[0]+1..]
  result = subproblem(remainder, sequences[1..])
  result += subproblem(pattern[idx + 1..], sequences) if pattern[idx] == '?'
  result
end

def find_first_block(pattern, length)
  pattern.chars.each_cons(length).with_index do |block, index|
    return index if block.all? { |elem| elem == '#' || elem == '?' } && pattern[index+length] != '#'
    return nil if block[0] == '#'
  end
  nil
end



solution = (0...rows.length).map do |index|
  subproblem(patterns[index], sequences[index])
end.sum

puts solution
