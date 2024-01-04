INPUT_FILE = __dir__ + "/input.txt"

lines = File.readlines(INPUT_FILE)

directions = lines[0].strip.split('')
point_map = lines[2..].map { |line| line.split('=').map(&:strip) }
                      .map { |entry| [entry[0], entry[1].gsub(/\(|\)/, '').split(',').map(&:strip)] }.to_h

starters = point_map.keys.select { |key| key[-1] == 'A' }

costs = starters.map do |key|
  steps = 0
  idx = 0
  until key[-1] == 'Z'
    idx = 0 if idx == directions.length
    steps += 1
    direction = directions[idx] == 'L' ? 0 : 1

    key = point_map[key][direction]
    idx += 1
  end
  steps
end

puts costs.reduce(1, :lcm)