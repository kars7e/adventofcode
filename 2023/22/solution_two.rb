example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

lines = File.readlines(INPUT_FILE)
coords = lines.map { |l| l.strip.split('~') }.map { |coords| coords.map { |z| z.split(',').map(&:to_i) } }
xvalues, yvalues, zvalues = lines.map { |l| l.strip.split('~') }.flatten.map { |z| z.split(',').map(&:to_i) }.transpose
($xmax, $ymax, $zmax) = [xvalues, yvalues, zvalues].map(&:max)

def points_below(l, r)
  z = l[2]
  (l[0]..r[0]).map do |x|
    (l[1]..r[1]).map do |y|
      [x, y, z - 1]
    end
  end.flatten(1)
end

def points_above(l, r)
  z = r[2]
  (l[0]..r[0]).map do |x|
    (l[1]..r[1]).map do |y|
      [x, y, z + 1]
    end
  end.flatten(1)
end

$world = {}
coords.each do |l, r|
  l.zip(r).then do |(lx, rx), (ly, ry), (lz, rz)|
    (lx..rx).each do |x|
      (ly..ry).each do |y|
        (lz..rz).each do |z|
          $world[[x, y, z]] = [l, r]
        end
      end
    end
  end
end

def move_below(l, r)
  l.zip(r).then do |(lx, rx), (ly, ry), (lz, rz)|
    (lx..rx).each do |x|
      (ly..ry).each do |y|
        (lz..rz).each do |z|
          $world[[x, y, z]] = nil
          raise "ERROR" if $world[[x, y, z - 1]]
          $world[[x, y, z - 1]] = [l, r]
        end
      end
    end
  end
end

def print_sides(side)
  $zmax.downto(1).each do |z|
    points = $world.select { |k, _| k[2] == z }.keys
    idx = 0 if side == 'x'
    idx = 1 if side == 'y'

    line = (0..$ymax).map do |col|
      v = points.find { |p| p[idx] == col }
      v ? '#' : '.'
    end.join('')
    puts line
  end
end

modified = []
while modified != coords
  modified = coords
  modified.sort_by { |l, r| l[2] }.each do |l, r|
    until l[2] == 1 || points_below(l, r).any? { |p| $world[p] }
      move_below(l, r)
      l[2] = l[2] - 1
      r[2] = r[2] - 1
    end
  end
end

coords = modified

def brick_falling_bfs(brick)
  memo = {}
  stack = above_no_support(brick, memo)
  return 0 if stack.empty?
  while stack.any?
    fallen = stack.pop
    memo[fallen] = true
    stack += above_no_support(fallen, memo).reject { |b| memo[b] }
  end
  memo.keys.length
end

def above_no_support(brick, memo)
  points_above(*brick).map { |p| $world[p] }.compact.select { |other| points_below(*other).none? { |point| $world[point] && $world[point] != brick && !memo[$world[point]] } }
end

solution = coords.sort_by { |l, r| r[2] }.reverse.map do |brick|
  brick_falling_bfs(brick)
end.inject(:+)
puts solution



