example = false
file = example ? 'example' : 'input'
$detection_range = [200000000000000, 400000000000000]
$detection_range = [7, 27] if example
INPUT_FILE = __dir__ + "/#{file}.txt"

$stones = File.readlines(INPUT_FILE).map { |row| row.strip.split('@').map(&:strip).map { |z| z.split(',').map(&:strip).map(&:to_i) } }
              .map { |coords, steps| [coords[..-2], steps[..-2]] }.to_h

def intersection(stone1, stone2)
  ys1, xs1 = $stones[stone1].map(&:to_f)
  ys2, xs2 = $stones[stone2].map(&:to_f)
  x1, y1 = stone1.map(&:to_f)
  x2, y2 = stone2.map(&:to_f)

  ys1 = -ys1
  ys2 = -ys2

  denominator = xs1 * ys2 - xs2 * ys1
  if denominator == 0
    puts "{stone1} and {stone2} are parallel"
    return nil
  end

  numerator_x = ys2 * (xs1 * x1 + ys1 * y1) - ys1 * (xs2 * x2 + ys2 * y2)
  numerator_y = xs1 * (xs2 * x2 + ys2 * y2) - xs2 * (xs1 * x1 + ys1 * y1)
  inter = [numerator_x / denominator, numerator_y / denominator]

  direction_1 = stone1[0] + $stones[stone1][0]
  direction_2 = stone2[0] + $stones[stone2][0]

  x_in_future = (inter[0] > stone1[0] && direction_1 > stone1[0]) || (inter[0] < stone1[0] && direction_1 < stone1[0])
  y_in_future = (inter[0] > stone2[0] && direction_2 > stone2[0]) || (inter[0] < stone2[0] && direction_2 < stone2[0])
  inter if x_in_future && y_in_future
end

solution = $stones.keys.combination(2).map do |stone1, stone2|
  intersection(stone1, stone2)
end.compact
solution = solution.select { |coords| coords.all? { |coord| coord.between?(*$detection_range) } }.count

puts solution