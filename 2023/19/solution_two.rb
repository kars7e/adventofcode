example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

lines = File.readlines(INPUT_FILE)
idx = lines.index("\n")
$rules_map = lines[0...idx].map { |line| line.strip.split('{').then { |row| [row[0], row[1].gsub(/[}]/, '').split(',')] } }.to_h

$rules_map.each do |label, rules|
  $rules_map[label] = rules.map { |rule| rule.split(':').then { |result| result.length > 1 ? [result[0].split(/([<>])/), result[1]] : result[0] } }
end

FLIP = {
  '>' => '<=',
  '<' => '>=',
  '>=' => '<',
  '<=' => '>',
}

UPPER_LIMIT = 4000

def range(value, operand)
  case operand
  when '>'
    [value + 1, UPPER_LIMIT]
  when '>='
    [value, UPPER_LIMIT]
  when '<'
    [1, value - 1]
  when '<='
    [1, value]
  end
end

def merge_intervals(interval, intervals)
  return [interval].to_h if intervals.nil? || intervals.empty?
  letter = interval[0]
  range = interval[1]
  range2 = intervals[letter]
  new_range = [[range[0], range2[0]].max, [range[1], range2[1]].min]
  raise "ERROR" if new_range[1] < new_range[0]

  intervals.merge([[letter, new_range]].to_h)
end

$visited = []

def subproblem(rule_name, to_filter = { 'x' => [1, 4000], 'm' => [1, 4000], 'a' => [1, 4000], 's' => [1, 4000] })
  $visited << rule_name
  ruleset = $rules_map[rule_name]
  result = []

  ruleset.each do |rule|
    if rule[0].kind_of?(Array)
      (letter, operand, value) = rule[0]
      value = value.to_i
      range = range(value, operand)
      negative_range = range(value, FLIP[operand])
      if rule[1] == 'A'
        result << merge_intervals([letter, range], to_filter)
      elsif rule[1] == 'R'
      else
        temp = subproblem(rule[1], merge_intervals([letter, range], to_filter))
        result += temp unless temp.nil?
      end
      to_filter = merge_intervals([letter, negative_range], to_filter)
    elsif rule == 'A'
      return result + [to_filter]
    elsif rule == 'R'
      return result
    else
      temp = subproblem(rule, to_filter)
      result += temp unless temp.nil?
      return result
    end
  end

  raise "ERROR"
end

allowed_ranges = subproblem('in')

puts allowed_ranges.map { |range| range.values.map { |r| r[1] - r[0] + 1 }.reduce(&:*) }.sum
