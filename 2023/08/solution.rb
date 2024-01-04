INPUT_FILE = __dir__ + "/input.txt"

lines = File.readlines(INPUT_FILE)

directions = lines[0].strip.split('')
point_map = lines[2..].map { |line| line.split('=').map(&:strip)}
                      .map {|entry| [entry[0], entry[1].gsub(/\(|\)/, '').split(',').map(&:strip)]}.to_h

current = 'AAA'
steps = 0
idx = 0
while current != 'ZZZ'
  idx = 0 if idx == directions.length
  steps+=1
  direction = directions[idx] == 'L' ? 0 : 1
  current = point_map[current][direction]
  idx+=1
end

puts steps
