INPUT_FILE = __dir__ + "/input.txt"

def is_digit?(s)
  code = s.ord
  48 <= code && code <= 57
end

data = File.readlines(INPUT_FILE)
seeds = data[0].split(':')[1].strip.split(' ').map(&:to_i).each_slice(2).to_a

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

def translate_seeds(mappings, seeds)
  mappings.each do |mapping|
    seeds.each do |seed|
      mapping.each do |mapping_entry|
        source_start = mapping_entry[1]
        dest_start = mapping_entry[0]
        mapping_range = mapping_entry[2]
        seed_start = seed[0]
        seed_range = seed[1]

        if source_start + mapping_range > seed_start && source_start < seed_start + seed_range
          seed[0] = dest_start + [0, seed_start - source_start].max
          seed[1] = [seed_start + seed_range, source_start + mapping_range].min - [source_start, seed_start].max

          if seed_start < source_start
            seeds << [seed_start, source_start - seed_start]
          end

          if seed_start + seed_range > source_start + mapping_range
            seeds << [source_start + mapping_range, seed_start + seed_range - source_start - mapping_range]
          end
          break
        end
      end
    end
  end
  seeds
end

min = translate_seeds(mappings, seeds).map(&:first).min
puts "MIN: ", min
