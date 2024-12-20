using DataStructures

f = open(joinpath(@__DIR__, "input.txt"), "r")
table = stack(split.(readlines(f), ""))
close(f)

start_block = findfirst(==("S"), table)
end_block = findfirst(==("E"), table)
directions = [CartesianIndex(dir) for dir in [(-1, 0), (1, 0), (0, -1), (0, 1)]]

function neighs(coords)
    [coords + dir for dir in directions if checkbounds(Bool, table, coords + dir)]
end

function bfs(table)
    visited = Dict{CartesianIndex,Int64}()
    to_visit = Queue{Tuple{CartesianIndex{2},Int64}}()
    enqueue!(to_visit, (start_block, 0))
    while !isempty(to_visit)
        current, cost = dequeue!(to_visit)
        if haskey(visited, current)
            continue
        end
        visited[current] = cost
        enqueue!.(Ref(to_visit), [(neigh, cost + 1) for neigh in neighs(current) if table[neigh] != "#"])
    end
    visited
end


function solution1()
    graph = bfs(table)
    path = sort(collect(graph), by=x -> x[2])
    [1 for (tile, start_cost) in path
     for dir in directions if table[tile+dir] == "#" &&
         haskey(graph, tile + dir + dir) &&
         graph[tile+dir+dir] - start_cost >= 102] |> sum
end

function solution2()
    graph = bfs(table)
    path = sort(collect(graph), by=x -> x[2])
    solution = 0
    for (start_tile, start_cost) in path
        for (end_tile, end_cost) in path[start_cost+2:end]
            distance = abs(end_tile[1] - start_tile[1]) + abs(end_tile[2] - start_tile[2])
            if distance <= 20 && end_cost - start_cost - distance >= 100
                solution += 1
            end
        end
    end
    solution
end

function solution2b()
    graph = bfs(table)
    path = sort(collect(graph), by=x -> x[2])

    [1 for (start_tile, start_cost) in path
     for distance in [CartesianIndex(x, y) for x = -20:20, y = -20:20 if abs(x) + abs(y) <= 20]
     if haskey(graph, start_tile + distance) &&
        graph[start_tile+distance] - start_cost - abs(distance[1]) - abs(distance[2]) >= 100] |> sum
end

println("solution1: ", @time solution1())
println("solution2: ", @time solution2())
println("solution2b: ", @time solution2b())