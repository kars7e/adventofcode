INPUT_FILE = __dir__ + "/input.txt"

def is_digit?(s)
  code = s.ord
  48 <= code && code <= 57
end

$digit_names = %w[one two three four five six seven eight nine]
$digit_name_to_int = $digit_names.each_with_object({}).with_index do |(name, acc), index|
  acc[name] = (index + 1)
end

def find_digit_words(line)
  digit_positions = {}
  $digit_names.each do |digit_name|
    position = 0
    loop do
      result = line.index(digit_name, position)
      break if result.nil?
      digit_positions[result] = $digit_name_to_int[digit_name]
      position = result + 1
    end
  end
  digit_positions
end

solution = File.open(INPUT_FILE).each.map do |line|
  word_digits = find_digit_words(line)
  digits = line.split('').each_with_object([]).with_index do |(char, acc), index|
    if is_digit?(char)
      acc << char
    elsif word_digits.has_key?(index)
      acc << word_digits[index].to_s
    end
  end

  [digits.first, digits.last].join.to_i
end.sum

puts solution
