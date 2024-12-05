require 'set'
INPUT_FILE = __dir__ + "/input.txt"

$rules = Hash.new { |h, k| h[k] = Set.new }

$correct_updates = []
$incorrect_updates = []

def process_rule(rule)
  (before, after) = rule.split("|").map(&:to_i)
  $rules[after] << before
end

def process_update(line)
  update = line.split(",").map(&:to_i)
  visited = Set.new
  update.reverse.each do |num|
    if visited.intersection($rules[num]).empty?
      visited << num
    else
      $incorrect_updates << update
      return
    end
  end
  $correct_updates << update
end

File.open(INPUT_FILE).map do |line|
  if line.include?("|")
    process_rule(line)
  elsif line.include?(",")
    process_update(line)
  end
end

solution1 = $correct_updates.map { |seq| seq[seq.length / 2] }.sum
puts solution1

solution2 = $incorrect_updates.map do |seq|
  seq.sort do |a, b|
    next -1 if $rules[b].include?(a)
    next 1 if $rules[a].include?(b)
    0
  end
end.map { |seq| seq[seq.length / 2] }.sum
puts solution2