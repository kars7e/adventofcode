f = open(joinpath(@__DIR__, "input.txt"), "r")
inputs = readlines(f)
close(f)

const prun_c = 1 << 24
step1(n) = (n ⊻ n << 6) % prun_c
step2(n) = (n ⊻ n >> 5) % prun_c
step3(n) = (n ⊻ n << 11) % prun_c
secret(n) = n |> step1 |> step2 |> step3
last_digit(n) = digits(n)[1]

function secret_repeated(n, N)
    reduce((n, _) -> secret(n), 1:N, init=n)
end

function changes(n, N)
    start = last_digit(n)
    result = Int[]
    for _ in 1:N
        n = secret(n)
        next_number = last_digit(n)
        push!(result, next_number - start)
        start = next_number
    end
    result
end

function sequences(n)
    chs = changes(n, 2000)
    cur = last_digit(n) + sum(chs[1:3])
    result = Dict{Tuple{Int8,Int8,Int8,Int8},Int64}()
    for sequence in zip(chs, chs[2:end], chs[3:end], chs[4:end])
        cur += sequence[4] # current sequence value 
        if !haskey(result, sequence)
            result[sequence] = cur
        end
    end
    result
end

function solution1()
    sum([secret_repeated(parse(Int, input), 2000) for input in inputs])
end

function solution2()
    all_seqs = Dict{Tuple{Int8,Int8,Int8,Int8},Int64}()
    for input in inputs
        for (seq, val) in sequences(parse(Int, input))
            all_seqs[seq] = get(all_seqs, seq, 0) + val
        end
    end

    all_seqs |> values |> maximum
end

println("solution1: ", @time solution1())
println("solution2: ", @time solution2())