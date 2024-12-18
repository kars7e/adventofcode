map_values = Dict{Vector{Int64}, String}()
dimension = 70

function neighbours(block)
    [block + dir for dir in [[-1,0],[1,0],[0,1],[0,-1]] if all(block + dir .<= dimension) && all(block + dir .>= 0) && get(map_values, block+dir, ".") == "."] 
end

function bfs(neighbours::Function)
    visited = Dict{Vector{Int64}, Int64}()
    to_visit = [([0,0], 0)]

    while !isempty(to_visit)
        current, cost = popfirst!(to_visit)
        if haskey(visited, current) && get(visited, current, 0) <= cost
            continue
        end
        
        visited[current] = cost

        for neigh in neighbours(current)
            if !haskey(visited, neigh) || get(visited, neigh, 0) > cost + 1
                push!(to_visit, (neigh, cost + 1))
            end
        end
    end
    visited
end

function parse_line(line)
    map((number) -> parse(Int, number), split(line, ","))
end

function add_bytes(bytes)
    for (x, y) in bytes
        map_values[[x,y]] = "#"
    end
end

function reset()
    global map_values = Dict{Vector{Int64}, String}()
    map_values
end

f = open(joinpath(@__DIR__, "input.txt"), "r")
lines = readlines(f)
close(f)
available_bytes = map(parse_line, lines)

function min_path()
    graph = bfs(neighbours)
    get(graph, [70,70], -1)
end

function bin_search()
    left = 1
    right = size(available_bytes)[1]
    
    while left != right
        middle = floor(Int, (left + right) / 2)
        reset()
        add_bytes(available_bytes[1:middle])
        path = min_path()
        if path > 0
            left = middle + 1
        else
            right = middle
        end
    end

    available_bytes[left]
end

function solution1()
    add_bytes(available_bytes[begin:1024])
    min_path()
end



function solution2()
    bin_search()
end

println("solution1: ", @time solution1())
println("solution2: ", @time solution2())
