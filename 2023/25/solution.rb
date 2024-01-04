require 'set'
example = true
file = example ? 'example' : 'input'
INPUT_FILE = __dir__ + "/#{file}.txt"

$example_result = [['hfx', 'pzl'], ['bvb', 'cmg'], ['nvd', 'jqt']].map(&:sort)
srand
$lines = File.readlines(INPUT_FILE)
             .map { |row| row.strip.split(':').map(&:strip) }
             .map { |from, to_list| [from, Set.new(to_list.split(' '))] }.to_h

$neighbors = $lines.clone.map { |k, v| [k, Set.new(v)] }.to_h
$neighbors.keys.each { |k| $neighbors[k].each { |neigh| $neighbors[neigh] ||= Set.new; $neighbors[neigh] << k } }

$nodes = $neighbors.keys
$edges = $lines.flat_map { |k, v| v.map { |neigh| [k, neigh] } }.uniq

def contractions
  curr_nodes = {}
  $nodes.each { |node| curr_nodes[node] = [node] }
  adjacency = $lines.clone.map { |k, v| [k, Set.new(v)] }.to_h
  while curr_nodes.keys.length > 2
    to_merge = adjacency.keys.sample
    to_remove = adjacency[to_merge].to_a.sample

    adjacency[to_merge] += adjacency.delete(to_remove) if adjacency[to_remove]
    adjacency[to_merge].subtract([to_merge, to_remove])

    adjacency.keys.select { |k| adjacency[k].include?(to_remove) }.each { |k| adjacency[k].delete(to_remove); adjacency[k] << to_merge unless adjacency[to_merge].include?(k); adjacency.delete(k) if adjacency[k].empty? }
    adjacency.delete(to_merge) if adjacency[to_merge].empty?
    curr_nodes[to_merge] += curr_nodes.delete(to_remove)
  end

  curr_nodes.values
end

def contractions_target(nodes, adj, target)
  curr_nodes = {}
  nodes.each { |node| curr_nodes[node] = [node] }
  adjacency = adj.clone.map { |k, v| [k, Set.new(v)] }.to_h
  while curr_nodes.keys.length > target
    to_merge = adjacency.keys.sample
    to_remove = adjacency[to_merge].to_a.sample

    adjacency[to_merge] += adjacency.delete(to_remove) if adjacency[to_remove]
    adjacency[to_merge].subtract([to_merge, to_remove])

    adjacency.keys.select { |k| adjacency[k].include?(to_remove) }.each { |k| adjacency[k].delete(to_remove); adjacency[k] << to_merge unless adjacency[to_merge].include?(k); adjacency.delete(k) if adjacency[k].empty? }
    adjacency.delete(to_merge) if adjacency[to_merge].empty?
    curr_nodes[to_merge] += curr_nodes.delete(to_remove)
  end

  [curr_nodes.keys, adjacency]
end

def fast_contractions(nodes, adj)
  if nodes.length < 6
    contractions_target(nodes, adj, 2)
  else
    t = ((1 + nodes.length) / 1.414).floor.to_i

    nodes1, adj1 = contractions_target(nodes, adj, t)
    nodes2, adj2 = contractions_target(nodes, adj, t)

    [fast_contractions(nodes1, adj1), fast_contractions(nodes2, adj2)].min { |a, b| a[1].count <=> b[1].count }
  end
end

def attempt_min_cuts
  contracted = fast_contractions($nodes, $lines)
  return nil if contracted[1] != 3
  contracted[1]
end

def find_min_cuts
  min_cuts = nil
  counter = 1
  while min_cuts.nil?
    min_cuts = attempt_min_cuts
    counter += 1
  end

  puts "attempt #{counter} succeeded"
  min_cuts
end

puts find_min_cuts