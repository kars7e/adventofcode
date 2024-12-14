require 'benchmark'
INPUT_FILE = __dir__ + "/input.txt"

robots = []

File.readlines(INPUT_FILE).each do |line|
  robots << line.scan(/p=([\-\d]+),([\-\d]+) v=([\-\d]+),([\-\d]+)/).flatten.map(&:to_i)
end

$width = 101
$height = 103

def move_robot(robot, iterations)
  (px, py, vx, vy) = robot
  [(px + vx * iterations) % $width, (py + vy * iterations) % $height, vx, vy]
end

def print_robots(robots_hash)
  puts((0...$height).map do |y|
    (0...$width).map do |x|
      robots_hash[[x, y]] == 0 ? '.' : '#'
    end.join
  end.join("\n"))
end

def solution1(robots)
  robots
    .map { |robot| move_robot(robot, 100) }
    .reject { |x, y| x == $width / 2 || y == $height / 2 }
    .group_by { |x, y| [x > $width / 2, y > $height / 2] }
    .values.map { |v| v.size }.inject(&:*)
end

puts solution1(robots)

def solution2(robots)
  robots = robots.dup
  (1..10000).find do |x|
    robots = robots.map { |robot| move_robot(robot, 1) }
    robots_hash = robots.map { |robot| robot[0..1] }
                        .reduce(Hash.new(0)) { |h, r| h[r] += 1; h }
    robots_hash.values.all? { |v| v <= 1 }
  end
end

puts solution2(robots)

def solution2_distance(robots)
  robots = robots.dup
  min_distance = Float::INFINITY
  min_repeat = 0
  (1..10000).map do |x|
    robots = robots.map { |robot| move_robot(robot, 1) }
    total_distance = 0
    robots.combination(2).each do |r1, r2|
      total_distance += (r1[0] - r2[0]).abs + (r1[1] - r2[1]).abs
      break if total_distance >= min_distance
    end
    if total_distance < min_distance
      min_distance = total_distance
      min_repeat = x
    end
  end
  min_repeat
end

puts solution2_distance(robots)



