f = open(joinpath(@__DIR__, "input.txt"), "r")
input = readline(f)
close(f)

DIRECTIONS = Dict([
    ('^', [0, 1]),
    ('<', [-1, 0]),
    ('v', [0, -1]),
    ('>', [1, 0])
])

function visit_one(position, visited, direction)
    dir = get(DIRECTIONS, direction, 0)
    new_position = position + dir
    visited[new_position] = get(visited, new_position, 0) + 1
    [new_position, visited]
end

function visit(directions)
    visited = Dict([([0, 0], 1)])
    reduce((acc, op) -> visit_one(acc[1], acc[2], op), directions, init=[[0, 0], visited])
    visited
end

function houses_visited(directions)
    length(collect(values(visit(directions))))
end

function visited_with_robot(directions)
    length(collect(values(merge(visit(directions[1:2:end]), visit(directions[2:2:end])))))
end

println("solution1: ", houses_visited(input))
println("solution2: ", visited_with_robot(input))


