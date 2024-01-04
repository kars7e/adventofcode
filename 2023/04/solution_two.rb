INPUT_FILE = __dir__ + "/input.txt"

def winnings(gamecfg)
  (winners, given) = gamecfg.split('|').map(&:strip).map { |arr| arr.split(' ') }.map { |arr| arr.map(&:to_i) }.map(&:sort)
  given.intersection(winners).length
end

winnings_map = Hash.new { |h, k| h[k] = 0 }
cardnumber = 0
File.open(INPUT_FILE).each.map do |line|
  to_copy = winnings(line.split(':')[1])
  (1..to_copy).each do |offset|
    winnings_map[cardnumber + offset] += 1
  end

  if winnings_map[cardnumber] > 0
    (1..to_copy).each do |offset|
      winnings_map[cardnumber + offset] += winnings_map[cardnumber]
    end
  end

  winnings_map[cardnumber] += 1

  cardnumber += 1

end

puts winnings_map.values.sum

