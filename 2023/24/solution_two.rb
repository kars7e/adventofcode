example = false
file = example ? 'example' : 'input'
$detection_range = [200000000000000, 400000000000000]
$detection_range = [7, 27] if example
INPUT_FILE = __dir__ + "/#{file}.txt"

$stones = File.readlines(INPUT_FILE).map { |row| row.strip.split('@').map(&:strip).map { |z| z.split(',').map(&:strip).map(&:to_i) } }
              .map { |coords, steps| [coords[..-2], steps[..-2]] }.to_h

def solve_day_24_part_2

end