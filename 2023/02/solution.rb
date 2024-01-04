INPUT_FILE = __dir__ + "/input.txt"

$redcubes = 12
$greencubes = 13
$bluecubes = 14

def possible_config?(cfg)
  cfg.split(',').map(&:strip).map do |colorcfg|
    (count, color) = colorcfg.split(' ')
    return false if color == 'red' && count.to_i > $redcubes
    return false if color == 'green' && count.to_i > $greencubes
    return false if color == 'blue' && count.to_i > $bluecubes
  end
  true
end

def possible_game?(gamecfg)
  gamecfg.split(';').map { |cfg| possible_config?(cfg) }.all?(true)
end

solution = File.open(INPUT_FILE).each.map do |line|
  (gameidstr, gamecfg) = line.split(':')
  gameid = gameidstr.split(' ')[1]
  if possible_game?(gamecfg)
    gameid.to_i
  else
    nil
  end
end.compact.sum

puts solution

