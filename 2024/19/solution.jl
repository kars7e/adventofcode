using Memoization

@memoize function find(pattern, towels)
    if isempty(pattern)
        1
    else
        sum(Int[find(pattern[length(towel)+1:end], towels) for towel in towels if startswith(pattern, towel)])
    end
end

f = open(joinpath(@__DIR__, "input.txt"), "r")
towels = split(readline(f), ", ")
readline(f)
patterns = readlines(f)
close(f)

function process((solution1, solution2), pattern)
    found = find(pattern, towels)
    if found > 0
        solution1 += 1
    end
    (solution1, solution2 + found)
end

@time solution1, solution2 = reduce(process, patterns, init=(0, 0))
println("solution1: ", solution1)
println("solution2: ", solution2)
