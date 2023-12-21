example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

lines = File.readlines(INPUT_FILE)
idx = lines.index("\n")
rules_map = lines[0...idx].map { |line| line.strip.split('{').then { |row| [row[0], row[1].gsub(/[}]/, '').split(',')] } }.to_h

rules_map.each do |label, rules|
  rules_map[label] = rules.map { |rule| rule.split(':').then { |result| result.length > 1 ? result : result[0] } }
end

Part = Struct.new(:x, :m, :a, :s) do
  def apply(rule)
    return rule.split('>').then { |attr, value| send(attr) > value.to_i } if rule.include?('>')
    rule.split('<').then { |attr, value| send(attr) < value.to_i }
  end

  def rating
    x + m + a + s
  end
end

parts = lines[idx + 1..].map { |line| line.gsub(/[{}]/, '').split(',').then { |row| Part.new(*row.map { |attr| attr.split('=')[1].to_i }) } }

sum = 0
parts.each do |part|
  rule_key = 'in'
  result = rule_key
  puts "Part #{part.inspect} applying rule #{rule_key}"
  while result != 'A' && result != 'R'
    puts "No key #{result}" unless rules_map.has_key?(result)
    candidate = rules_map[result]
    candidate.each do |rule|
      unless rule.kind_of?(Array)
        result = rule
        break
      end
      if part.apply(rule[0])
        result = rule[1]
        break
      end
    end
  end

  if result == 'R'
    puts "Part #{part.inspect} rejected"
  end

  if result == 'A'
    puts "Part #{part.inspect} accepted"
    sum += part.rating
  end
end

puts sum