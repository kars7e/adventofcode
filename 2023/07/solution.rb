INPUT_FILE = __dir__ + "/input.txt"

figures = %w[A K Q J T 9 8 7 6 5 4 3 2]
$figure_map = figures.reverse.map.with_index { |figure, index| [figure, index] }.to_h

def compare_hands(hand1, hand2)
  figures1 = hand1.split('')
  figures2 = hand2.split('')
  tally1 = figures1.tally
  tally2 = figures2.tally

  if tally1.keys.length < tally2.keys.length
    return 1
  elsif tally1.keys.length > tally2.keys.length
    return -1
  end

  if tally1.values.sort[-1] > tally2.values.sort[-1]
    return 1
  elsif tally1.values.sort[-1] < tally2.values.sort[-1]
    return -1
  end

  if tally1.values.sort[0] > tally2.values.sort[0]
    return 1
  elsif tally1.values.sort[0] < tally2.values.sort[0]
    return -1
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