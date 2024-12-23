using DataStructures
using Graphs
using MetaGraphsNext

f = open(joinpath(@__DIR__, "input.txt"), "r")
edges_list = map((line) -> split(line, "-"), readlines(f))
close(f)

function compute_graph(edges)
    g = MetaGraph(Graph(); label_type=String, default_weight=1)
    for (src, dst) in edges
        add_vertex!(g, src)
        add_vertex!(g, dst)
        add_edge!(g, src, dst)
    end
    g
end

function solution1()
    graph = compute_graph(edges_list)
    solution = Set()
    for edge in edges(graph)
        intersection = intersect(all_neighbors(graph, edge.src), all_neighbors(graph, edge.dst))
        for cand in intersection 
            if any((node) -> startswith(label_for(graph, node), "t"), [edge.src, edge.dst, cand])
                push!(solution, sort([edge.src, edge.dst, cand]))
            end
        end
    end
    length(solution)
end

function solution2()
    graph = compute_graph(edges_list)
    max_cliques = maximal_cliques(graph)
    longest = max_cliques[findmax(length, max_cliques)[2]]
    join(sort(map((n) -> label_for(graph, n),longest)), ",")
end

println("solution1: ", @time solution1())
println("solution2: ", @time solution2())