example = false
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

lines = File.readlines(INPUT_FILE)
pics = []

until lines.nil?
  idx = lines.index("\n") || lines.length
  pics << lines[0...idx].map { |row| row.strip.split('') }
  lines = lines[idx + 1..]
end

def find_mirror(pic)
  start = pic.length / 2
  idx = 0
  while idx <= (pic.length / 2)
    return start - idx if check_mirror(pic, start - idx)
    return start + idx if check_mirror(pic, start + idx)
    idx += 1
  end
end

def check_mirror(pic, i)
  if i > pic.length / 2.0
    a = pic[i..]
    b = pic[2 * i - pic.length...i].reverse
  else
    a = pic[i...2 * i]
    b = pic[0...i].reverse
  end
  return false if a.nil? || a.empty?
  mismatch = 0
  a.zip(b).each do |arow, brow|
    arow.zip(brow).each do |ae, be|
      mismatch += 1 if ae != be
      return false if mismatch > 1
    end
  end
  return mismatch == 1
end

solution = pics.map do |pic|
  tpic = pic.transpose
  horizontal = find_mirror(pic) || 0
  vertical = find_mirror(tpic) || 0
  vertical + 100 * horizontal
end.sum

puts solution


