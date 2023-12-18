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

solution = 0
candidates = {}
prev_numbers = {}
numbers = Hash.new { |h, k| h[k] = [] }
File.open(INPUT_FILE).each.map do |line_now|
  line_now.strip!

  gears = []
  line_now.scan(/\d+|\*/) do |token|
    if token == '*'
      gears << Regexp.last_match.offset(0).first
    else
      startpos = Regexp.last_match.offset(0).first - 1
      startpos = 0 if startpos < 0
      endpos = Regexp.last_match.offset(0).last
      (startpos..endpos).to_a.each do |pos|
        numbers[pos] << token.to_i
      end
    end
  end

  # row below gears
  candidates.each do |k, _|
    if numbers.has_key?(k)
      candidates[k] += numbers[k]
    end

    if candidates[k].length == 2
      solution += candidates[k].inject(&:*)
    end
  end

  # reset candidates
  candidates = {}
  gears.each do |gear|
    candidates[gear] = []
  end

  candidates.each do |k, _|
    if numbers.has_key?(k)
      candidates[k] += numbers[k]
    end

    if prev_numbers.has_key?(k)
      candidates[k] += prev_numbers[k]
    end
  end

  prev_numbers = numbers
  numbers = Hash.new { |h, k| h[k] = [] }
end

puts solution



