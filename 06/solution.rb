INPUT_FILE = __dir__ + "/input.txt"

def is_digit?(s)
  code = s.ord
  48 <= code && code <= 57
end

def distance_traveled(pressed_time, race_time)
  (race_time - pressed_time) * pressed_time
end

data = File.readlines(INPUT_FILE)
time = data[0].split(':')[1].strip.split(' ').map(&:to_i)
distance = data[1].split(':')[1].strip.split(' ').map(&:to_i)
races = time.zip(distance)

result = races.map do |race|
  (1..race[0]).map { |pressed_time| distance_traveled(pressed_time, race[0]) }.select { |distance| distance > race[1] }.count
end.inject(&:*)

puts result

