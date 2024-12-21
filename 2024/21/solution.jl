using Combinatorics
using Memoization

f = open(joinpath(@__DIR__, "input.txt"), "r")
inputs = readlines(f)
close(f)

directions = Dict(zip(['<', '>', 'v', '^'], CartesianIndex.([(0, -1), (0, 1), (-1, 0), (1, 0)])))

numpad = ["X" "0" "A"
          "1" "2" "3"
          "4" "5" "6"
          "7" "8" "9"]
a_num_idx = findfirst(==("A"), numpad)

keypad = ["<" "v" ">"
          "X" "^" "A"]
a_key_idx = findfirst(==("A"), keypad)

function path(start, moves)
    reduce((steps, move) -> [steps; steps[end] + directions[move]], moves, init=[start])
end

function transitions(from, to, source=keypad)
    if from == to
        return [['A']]
    end

    dy, dx = Tuple(to - from)
    moves = repeat(dx < 0 ? "<" : ">", abs(dx)) * repeat(dy < 0 ? "v" : "^", abs(dy))

    possible_moves = collect(permutations(moves)) |> sort |> unique
    [[moves; 'A'] for moves in possible_moves if !any((move) -> source[move] == "X", path(from, moves))]
end

@memoize function best_moves(input, max_depth=2, cur_depth=0)
    cur_button = cur_depth == 0 ? a_num_idx : a_key_idx

    pad = cur_depth == 0 ? numpad : keypad
    min_length = 0
    for char in collect(input)
        next_button = findfirst(==(string(char)), pad)
        moves = transitions(cur_button, next_button, pad)
        if cur_depth == max_depth
            min_length += length(moves) > 0 ? length(moves[1]) : 1
        else
            min_length += minimum(map((move_seq) -> best_moves(join(move_seq, ""), max_depth, cur_depth + 1), moves))
        end
        cur_button = next_button
    end
    min_length
end

function solution1()
    sum([best_moves(input) * parse(Int, input[1:3]) for input in inputs])
end

function solution2()
    sum([best_moves(input, 25) * parse(Int, input[1:3]) for input in inputs])
end

println("solution1: ", @time solution1())
println("solution2: ", @time solution2())