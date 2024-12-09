require 'benchmark'
INPUT_FILE = __dir__ + "/input.txt"

input = File.open(INPUT_FILE).read

def checksum(blocks)
  blocks.each_with_index.inject(0) { |sum, (block, idx)| sum + block * idx }
end

def part1(files, spaces)
  result = []
  while files.size > 0 && spaces.size > 0
    result += files.shift
    space = spaces.shift
    while space > 0 && !files.empty?
      candidates = files.pop
      if candidates.size <= space
        result += candidates
        space -= candidates.size
      else
        result += candidates.pop(space)
        files.push(candidates)
        space = 0
      end
    end
  end
  checksum(result)
end

def part2(files, spaces)
  result = []
  consumed_spaces = Hash.new { |h, k| h[k] = [] }
  (files.size - 1).downto(1).each do |idx|
    candidate_idx = spaces[0...idx].find_index { |space| space >= files[idx].size }
    if candidate_idx
      consumed_spaces[candidate_idx] += files[idx]
      spaces[candidate_idx] -= files[idx].size
      files[idx] = [0] * files[idx].size
    end
  end

  (0...files.size).each do |idx|
    result += files[idx] if files[idx]
    result += consumed_spaces[idx] if consumed_spaces[idx]
    result += [0] * spaces[idx] if spaces[idx] && spaces[idx] > 0
  end

  checksum(result)
end

puts Benchmark.measure {
  (all_files, all_spaces) = input.split('').map(&:to_i).partition.with_index { |_, idx| idx.even? }
  all_files = all_files.map.with_index { |file, idx| [idx] * file }
  puts part1(all_files, all_spaces)
}

puts Benchmark.measure {
  (all_files, all_spaces) = input.split('').map(&:to_i).partition.with_index { |_, idx| idx.even? }
  all_files = all_files.map.with_index { |file, idx| [idx] * file }
  puts part2(all_files, all_spaces)
}