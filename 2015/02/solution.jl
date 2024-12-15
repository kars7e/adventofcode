f = open(joinpath(@__DIR__, "input.txt"), "r")
lines = readlines(f)
close(f)

function dimensions(box)
    map((number) -> parse(Int, number), match(r"(\d+)x(\d+)x(\d+)", box).captures)
end

function paper(box)
    (l, w, h) = box

    minimum([l * w, l * h, w * h]) + 2 * l * w + 2 * w * h + 2 * h * l
end

function ribbon(box)
    (l, w, h) = box
    l * w * h + minimum([2 * l + 2 * w, 2 * l + 2 * h, 2 * w + 2 * h])
end

println("solution1: ", sum([paper(dimensions(line)) for line in lines]))
println("solution2: ", sum([ribbon(dimensions(line)) for line in lines]))