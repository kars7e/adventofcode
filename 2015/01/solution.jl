
f = open(joinpath(@__DIR__, "input.txt"), "r")
input = readline(f)
close(f)

function val(char)
    char == ')' ? -1 : 1
end

function count_chars(input)
    sum(map(val, collect(input)))
end

function red(acc, op)
    (idx, symbol) = op
    (cur_sum, result) = acc
    cur_val = val(symbol)
    if cur_sum + cur_val == -1 && result == 0
        [cur_sum + cur_val, idx]
    else
        [cur_sum + cur_val, result]
    end
end


function find_first(input)
    reduce(red, enumerate(collect(input)), init = [0, 0])
end

println("answer1: ", count_chars(input))
println("answer2: ", find_first(input))