example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

data = File.readlines(INPUT_FILE).map { |row| row.strip.split('') }

def tilt(columns)
  columns.each do |column|
    cached_rocks = 0
    column.each_with_index do |obj, index|
      if obj == 'O'
        cached_rocks += 1
        column[index] = '.'
      end
      if obj == '#' && cached_rocks > 0
        while cached_rocks > 0
          column[index - cached_rocks] = 'O'
          cached_rocks -= 1
        end
      end
    end
    index = column.length
    while cached_rocks > 0
      column[index - cached_rocks] = 'O'
      cached_rocks -= 1
    end
  end

  columns
end

def cycle(result)
  result = tilt(result.reverse.transpose).transpose.reverse
  # west
  result = tilt(result.map(&:reverse)).map(&:reverse)
  # south
  result = tilt(result.transpose.reverse).reverse.transpose
  # east
  tilt(result)
end

def find_loop(result)
  cache = { }
  loop.with_index do | _ ,i|
    result = cycle(result)
    return [i-cache[result], cache[result] + 1] if cache.has_key?(result)
    cache[result] = i
  end
end

def process(data)
  loop_size, first_loop = find_loop(data)
  puts loop_size, first_loop
  cycles_to_run = first_loop + (1000000000-first_loop) % loop_size
  cycles_to_run.times do
    data = cycle(data)
  end
  calculate_load(data)
end

def calculate_load(data)
  data.reverse.map.with_index(1) do |row, index|
    row.select { |obj| obj == 'O' }.count.*(index)
  end.sum
end

puts process(data)
