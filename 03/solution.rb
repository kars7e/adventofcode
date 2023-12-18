INPUT_FILE = __dir__ + "/input.txt"

def is_digit?(s)
  code = s.ord
  48 <= code && code <= 57
end

def is_symbol?(s)
  return false if s.nil?
  !is_digit?(s) && s != '.'
end

def direct_neighbor?(line, positions)
  is_symbol?(line[positions.first - 1]) || is_symbol?(line[positions.last])
end

def neighbor?(line, positions)
  startpos = positions.first - 1
  startpos = 0 if startpos < 0
  endpos = positions.last
  endpos = line.length - 1 if endpos >= line.length

  line[startpos..endpos].split('').any? { |char| is_symbol?(char) }
end

part_numbers = []
candidates = {}
line_prev = nil

File.open(INPUT_FILE).each.map do |line_now|
  line_now.strip!
  unless candidates.empty?
    candidates.each do |positions, number|
      part_numbers << number.to_i if neighbor?(line_now, positions)
    end
    candidates = {}
  end

  line_now.scan(/\d+/) do |number|
    positions = Regexp.last_match.offset(0)
    if direct_neighbor?(line_now, positions)
      part_numbers << number.to_i
    elsif line_prev && neighbor?(line_prev, positions)
      part_numbers << number.to_i
    else
      candidates[positions] = number
    end
  end
  line_prev = line_now
end

puts part_numbers.sum



