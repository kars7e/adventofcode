import MD5

function md5(input)
    MD5.bytes2hex(MD5.md5(input))
end

function md5combined(input, i)
    md5(input * string(i))
end

function solution1(input)
    for i in 1:10^20
        startswith(md5combined(input, i), "00000") && return i
    end
end

function solution2(input)
    for i in 1:10^20
        startswith(md5combined(input, i), "000000") && return i
    end
end

f = open(joinpath(@__DIR__, "input.txt"), "r")
input = readline(f)
close(f)

println("solution1: ", solution1(input))
println("solution2: ", solution2(input))


