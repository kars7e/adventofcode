$neighbours = [[-1, 0], [1,0], [0, -1], [0, 1]]

$allowed_dirs = {
  '|' => [[0, 1], [0, -1]],
  '-' => [[1, 0], [-1, 0]],
  'L' => [[0, -1], [1, 0]],
  'J' => [[0, -1], [-1, 0]],
  '7' => [[0, 1], [-1, 0]],
  'F' => [[0, 1], [1, 0]]
}

INPUT_FILE = __dir__ + "/input.txt"
$matrix = File.readlines(INPUT_FILE).map { |row| row.split('') }
start_y = $matrix.find_index { |row| row.include?('S') }
start_x = $matrix[start_y].find_index('S')

def can_connect?(point, pipecoords)
  return false unless pipecoords[1] < $matrix.length && pipecoords[0] < $matrix[pipecoords[1]].length
  pipe = $matrix[pipecoords[1]][pipecoords[0]]
  return false unless $allowed_dirs.has_key?(pipe)
  $allowed_dirs[pipe].map { |x, y| [pipecoords[0] + x, pipecoords[1] + y] }.include?(point)
end

def accessible_neighbours(point)
  $neighbours.map { |x, y| [point[0] + x, point[1] + y] }.select { |coords| can_connect?(point, coords) }
end

visited = {}
to_visit = [[[start_x, start_y], 0]]
until to_visit.empty?
  visiting = to_visit.shift
  current = visiting[0]
  distance = visiting[1]
  if visited[current].nil? || visited[current] > distance
    visited[current] = distance
  end

  to_visit += accessible_neighbours(current).select { |neighbour| visited[neighbour].nil? || visited[neighbour] > distance + 1 }.map { |neighbour| [neighbour, distance + 1] }

end
puts visited.values.max
