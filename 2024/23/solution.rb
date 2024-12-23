INPUT_FILE = __dir__ + "/input.txt"
input = File.readlines(INPUT_FILE)

connected = Hash.new { |h, k| h[k] = Set.new }

input.map do |line|
  c1, c2 = line.strip.split("-")
  connected[c1] << c2
  connected[c2] << c1
end

solution = connected.keys.combination(3).select { |triple|triple.any? { |c| c.start_with?('t') }}.select { |triple| triple.all? { |c| ((triple - [c]) - connected[c].to_a).empty? } }
                                           .map(&:sort).uniq.count

puts solution









  