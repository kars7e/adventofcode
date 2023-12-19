INPUT_FILE = __dir__ + "/input.txt"

rows = File.readlines(INPUT_FILE).map{ |row| row.split(' ').map(&:to_i) }

def calculate_steps(row)
  row[1..].each_with_object([]).with_index do |(number, acc), index|
    acc << (number - row[index])
  end
end

solution = rows.map do |row|
  first_elems = []
  until row.uniq.length == 1
    first_elems << row[0]
    row = calculate_steps(row)
  end
  first_elems << row[0]
  first_elems.reverse.inject([0, 0]){ |acc, elem| [elem - acc[0], acc[0] ] }.first
end.sum

puts solution

