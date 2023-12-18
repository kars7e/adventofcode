INPUT_FILE = __dir__ + "/input.txt"

def is_digit?(s)
  code = s.ord
  48 <= code && code <= 57
end

data = File.readlines(INPUT_FILE)
seeds = data[0].split(':')[1].strip.split(' ').map(&:to_i)

mappings = []
mapping_id = 0
mappings[mapping_id] = []
data[3..279].each do |line|
  if is_digit?(line[0])
    mappings[mapping_id] << line.split(' ').map(&:to_i)
  elsif line.length > 1
    mapping_id += 1
    mappings[mapping_id] = []
  end
end

def map_seed(seed, mapping)
  mapping.each do |mapping_entry|
    if seed >= mapping_entry[1] && seed < mapping_entry[1] + mapping_entry[2]
      return mapping_entry[0] + seed - mapping_entry[1]
    end
  end
  return seed
end

puts seeds.inspect
mappings.each do |current_mapping|
  seeds = seeds.map { |seed| map_seed(seed, current_mapping) }
end
puts seeds.sort.inspect
puts seeds.min