INPUT_FILE = __dir__ + "/input.txt"

figures = %w[A K Q T 9 8 7 6 5 4 3 2 J]
$figure_map = figures.reverse.map.with_index { |figure, index| [figure, index] }.to_h

def hand_rank(hand)
  tally = hand.tally
  return 1 if tally.keys.length == 5
  return 2 if tally.keys.length == 4
  return 3 if tally.keys.length == 3 && tally.values.sort[-1] == 2
  return 4 if tally.keys.length == 3 && tally.values.sort[-1] == 3
  return 5 if tally.keys.length == 2 && tally.values.sort[-1] == 3
  return 6 if tally.keys.length == 2 && tally.values.sort[-1] == 4
  return 7 if tally.keys.length == 1
end

def j_rank(hand)
  j_count = hand.tally.fetch('J', 0)
  rank = hand_rank(hand)
  return rank if j_count == 0

  return 2 if rank == 1

  return 6 if rank == 3 && j_count == 2

  return rank + 2 if [2, 3, 4].include?(rank)

  return 7
end

def compare_hands(hand1, hand2)
  figures1 = hand1.split('')
  figures2 = hand2.split('')

  rank1 = j_rank(figures1)
  rank2 = j_rank(figures2)

  if rank1 < rank2
    return -1
  elsif rank1 > rank2
    return 1
  end

  figures1.zip(figures2).each do |figure1, figure2|
    next if $figure_map[figure1] == $figure_map[figure2]
    return $figure_map[figure1] > $figure_map[figure2] ? 1 : -1
  end
end

entries = File.readlines(INPUT_FILE).map { |entry| entry.split(' ').map(&:strip) }

sorted_hands = entries.sort do |entry1, entry2|
  compare_hands(entry1[0], entry2[0])
end

puts sorted_hands.map.with_index { |entry, index| entry[1].to_i * (index + 1) }.sum

