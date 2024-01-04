INPUT_FILE = __dir__ + "/input.txt"

rows = File.readlines(INPUT_FILE).map{ |row| row.split(' ').map(&:to_i) }

def calculate_steps(row)
  row[1..].each_with_object([]).with_index do |(number, acc), index|
    acc << (number - row[index])
  end
end

solution = rows.map do |row|
  last_elems = []
  until row.uniq.length == 1
    last_elems << row[-1]
    row = calculate_steps(row)
  end
  last_elems << row[-1]
  last_elems.sum
end.sum

puts solution

