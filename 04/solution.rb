INPUT_FILE = __dir__ + "/input.txt"

def points(gamecfg)
  (winners, given) = gamecfg.split('|').map(&:strip).map{|arr| arr.split(' ')}.map{|arr| arr.map(&:to_i)}.map(&:sort)
  given.intersection(winners).length > 0 ? 2.pow(given.intersection(winners).length - 1) : 0
end

solution = File.open(INPUT_FILE).each.map do |line|
  points(line.split(':')[1])
end.sum

puts solution

