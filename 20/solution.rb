example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

class Mod
  attr_accessor :sent_count, :received_count, :inputs, :outputs, :name

  def initialize(name, inputs = [], outputs = [])
    @sent_count = 0
    @received_count = 0
    @inputs = inputs
    @outputs = outputs
    @name = name
  end

  def add_input(input)
    @inputs << input
  end

  def to_s
    "#{self.class} #{name} "
  end
end

Pulse = Struct.new(:value, :from, :to) do
  def ==(other)
    return value == other.value if other.kind_of?(Pulse)
    value == other
  end
end

class Debug < Mod
  def initialize(name, inputs = [], outputs = [])
    super
  end

  def receive(pulse)
    []
  end
end

class FlipFlop < Mod
  def initialize(name, inputs = [], outputs = [])
    super
    @active = false
  end

  def receive(pulse)
    return [] if pulse == :high
    @active = !@active
    to_send = @active ? :high : :low

    @outputs.map { |output| Pulse.new(to_send, name, output) }
  end

  def to_s
    "#{self.name}=#{@active ? "1" : "0"}"
  end
end

class Conjunction < Mod
  def initialize(name, inputs = [], outputs = [])
    super
    @received_from = {}
  end

  def receive(pulse)
    @received_from[pulse.from] = pulse.value
    to_send = @received_from.values.any? { |v| v == :low } ? :high : :low
    @outputs.map { |output| Pulse.new(to_send, name, output) }
  end

  def state
    @received_from.values.size - @received_from.values.count(:low)
  end

  def to_s
    "#{self.name}=#{@received_from.values.count(:low)}/#{@received_from.values.size}"
  end

  def add_input(input)
    super
    @received_from[input] = :low
  end
end

class Broadcaster < Mod
  def initialize(name, inputs = [], outputs = [])
    super
    @high_sent = 0
    @low_sent = 0
  end

  def send(from)
    @low_sent += 1
    to_send = receive(:low)
    while to_send.any?
      pulse = to_send.shift
      sent(pulse)
      if from && from.include?(pulse.from) && pulse.value == :high
        yield pulse.from
      end

      to_send += $modules_map[pulse.to].receive(pulse)
    end
  end

  def sent(pulse)
    @high_sent += 1 if pulse.value == :high
    @low_sent += 1 if pulse.value == :low
  end

  def counters
    [@high_sent, @low_sent]
  end

  def get_signal(mod)
    $modules_map[mod].inputs.each
  end

  def state
    $modules_map.values.map(&:to_s).join(',')
  end

  def receive(pulse)
    @outputs.map { |output| Pulse.new(pulse, self, output) }
  end
end

MODULE_TYPES_MAP = {
  '%' => FlipFlop,
  '&' => Conjunction,
  'b' => Broadcaster,
}

lines = File.readlines(INPUT_FILE)
$modules_map = {}
lines.each do |line|
  line.split(' ')[0].then { |c| $modules_map[c[1..]] = MODULE_TYPES_MAP[c[0]].new(c[1..]) }
end

lines.each do |line|
  (mod_name, outputs) = line.split('->').map(&:strip).then { |cols| [cols[0][1..], cols[1].split(',').map(&:strip)] }
  $modules_map[mod_name].outputs = outputs.map do |out|
    $modules_map[out] = Debug.new(out) unless $modules_map.has_key?(out)
    out
  end
  outputs.each { |out| $modules_map[out].add_input($modules_map[mod_name].name) }
end

important_ones = $modules_map['rx'].inputs.map { |mod| $modules_map[mod].inputs }.flatten
# embarrassing
$modules_map['broadcaster'] = $modules_map.delete('roadcaster')
idx = 1
keep_going = true
cycles = {}
loop do
  $modules_map['broadcaster'].send(important_ones) do |mod|
    cycles[mod] = idx
    if cycles.keys.size == important_ones.size
      keep_going = false
      break
    end
  end

  idx += 1
  break unless keep_going
end

important_ones.each do |mod|
  puts "#{mod} #{cycles[mod]}"
end
#
puts cycles.values.inject(:lcm)



