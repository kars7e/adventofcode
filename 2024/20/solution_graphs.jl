using DataStructures
using Graphs
using MetaGraphsNext

f = open(joinpath(@__DIR__, "input.txt"), "r")
table = stack(split.(readlines(f), ""))
close(f)

start_block = findfirst(==("S"), table)
end_block = findfirst(==("E"), table)
directions = CartesianIndex.([(-1, 0), (1, 0), (0, -1), (0, 1)])

function compute_graph()
    g = MetaGraph(Graph(); label_type=CartesianIndex{2}, default_weight=1)
    for idx in CartesianIndices(table)
        if occursin(table[idx], "SE.")
            g[idx] = nothing
        end
    end

    for idx in labels(g)
        for dir in directions
            if haskey(g, idx + dir)
                g[idx, idx+dir] = nothing
            end
        end
    end

    state = dijkstra_shortest_paths(g, [code_for(g, start_block,)], trackvertices=true)
    g, state
end

function find_cheats(graph, graph_state, maxdist=2, target=100)
    sum = 0
    for start_vertex in map((idx) -> label_for(graph, idx), graph_state.closest_vertices)
        start_cost = graph_state.dists[code_for(graph, start_vertex)]
        for dist_vec in [CartesianIndex(x, y) for x = -maxdist:maxdist, y = -maxdist:maxdist if abs(x) + abs(y) <= maxdist]
            end_vertex = start_vertex + dist_vec
            distance = abs(dist_vec[1]) + abs(dist_vec[2])
            if haskey(graph, end_vertex)
                end_cost = graph_state.dists[code_for(graph, end_vertex)]
                if end_cost - start_cost - distance >= target
                    sum += 1
                end
            end
        end
    end
    sum
end

function solution1()
    find_cheats(compute_graph()...)
end

function solution2()
    find_cheats(compute_graph()..., 20)
end

println("solution1: ", @time solution1())
println("solution2: ", @time solution2())