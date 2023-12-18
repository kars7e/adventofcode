INPUT_FILE = __dir__ + "/input.txt"

$redcubes = 12
$greencubes = 13
$bluecubes = 14

def rgb_values(cfg)
  red = 0
  green = 0
  blue = 0
  cfg.split(',').map(&:strip).map do |colorcfg|
    (count, color) = colorcfg.split(' ')
    red = count.to_i if color == 'red'
    green = count.to_i if color == 'green'
    blue = count.to_i if color == 'blue'
  end
  [red, green, blue]
end

def set_power(gamecfg)
  max_red = 1
  max_green = 1
  max_blue = 1
  gamecfg.split(';').map { |cfg| rgb_values(cfg) }.each do |(red, green, blue)|
    max_red = red if red > max_red
    max_green = green if green > max_green
    max_blue = blue if blue > max_blue
  end
  max_red * max_green * max_blue
end

solution = File.open(INPUT_FILE).each.map do |line|
  set_power(line.split(':')[1])
end.compact.sum

puts solution

