example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

sequence = File.readlines(INPUT_FILE)[0].split(',')

def hashfunc(input)
  current = 0
  input.split('').each do |char|
    current += char.ord
    current *= 17
    current %= 256
  end
  current
end

def remove(label)
  ref = $boxes[hashfunc(label)].index { |lens| lens[0] == label }
  return if ref.nil?

  $boxes[hashfunc(label)].delete_at(ref)
end

$boxes = Hash.new { |h, k| h[k] = [] }

def insert(label, value)
  pos = $boxes[hashfunc(label)].index { |lens| lens[0] == label }
  if pos.nil?
    $boxes[hashfunc(label)] << [label, value]
  else
    $boxes[hashfunc(label)][pos] = [label, value]
  end
end

sequence.each do |step|
  if step.include?('=')
    insert(*step.split('='))
  else
    remove(*step.split('-')[0])
  end
end

solution = $boxes.map do |boxno, lenses|
  lenses.each_with_object(boxno).with_index.map { |(lens, index), box | (box +1) * (index + 1) * lens[1].to_i }.sum
end.sum

puts solution



