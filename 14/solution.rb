example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

columns = File.readlines(INPUT_FILE).reverse.map{ |row| row.strip.split('') }.transpose

load = 0
columns.each do |column|
  cached_rocks = 0
  column.each_with_index do |obj, index|
    cached_rocks += 1 if obj == 'O'
    if obj == '#' && cached_rocks > 0
      while cached_rocks > 0
        load += index - cached_rocks + 1
        cached_rocks -= 1
      end
    end
  end
  next if cached_rocks == 0

  index = column.length
  while cached_rocks > 0
    load += index - cached_rocks + 1
    cached_rocks -= 1
  end
end

puts load

