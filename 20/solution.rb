example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

class Mod
  attr_accessor :sent_count, :received_count, :inputs, :outputs

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

    @outputs.map { |output| Pulse.new(to_send, self, output) }
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
    @outputs.map { |output| Pulse.new(to_send, self, output) }
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

  def send
    @low_sent += 1
    to_send = receive(:low)
    while to_send.any?
      pulse = to_send.shift
      sent(pulse)
      to_send += pulse.to.receive(pulse)
    end
  end

  def sent(pulse)
    @high_sent += 1 if pulse.value == :high
    @low_sent += 1 if pulse.value == :low
  end

  def counters
    [@high_sent, @low_sent]
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
    $modules_map[out]
  end
  outputs.each { |out| $modules_map[out].add_input($modules_map[mod_name]) }
end

# embarrassing
$modules_map['broadcaster'] = $modules_map.delete('roadcaster')
1000.times { $modules_map['broadcaster'].send}

puts $modules_map['broadcaster'].counters.inject(&:*)