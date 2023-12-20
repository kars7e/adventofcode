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

puts sequence.map { |step| hashfunc(step)}.sum



  