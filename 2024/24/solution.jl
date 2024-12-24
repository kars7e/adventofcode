f = open(joinpath(@__DIR__, "input.txt"), "r")
inputs = readlines(f)
close(f)

splitter = findfirst(==(""), inputs)
start_state = inputs[1:splitter-1]
operations = inputs[splitter+1:end]
gates = Dict{String, Int}()

for line in start_state
    (wire, value) = split(strip(line), ": ")
    gates[wire] = parse(Int, value)
end

opers = Dict()
opers["AND"] = &
opers["OR"] = |
opers["XOR"] = xor

gate_funcs = Dict()
for line in operations
    (left, op, right, res) = match(r"(.+) (.+) (.+) -> (.+)", strip(line)).captures
    gate_funcs[res] = (left, op, right)
end

function calculate(res, operand=[])
    if haskey(gates, res)
        return gates[res]
    end
    
    (left, op, right) = gate_funcs[res]
    push!(operand, (left, op, right))
    gates[res] = opers[op](calculate(left, operand), calculate(right, operand))
    if startswith(res, "z")
        @show res, operand
    end
    gates[res]
end


solutionbit = reverse(join([calculate(register) for register in "z".*map((i) -> lpad(i, 2, "0"), 0:45)], ""))
solution = parse(Int, solutionbit, base=2)

xbit = reverse(join([calculate(register) for register in "x".*map((i) -> lpad(i, 2, "0"), 0:44)], ""))
xvalue = parse(Int, xbit, base=2)
ybit = reverse(join([calculate(register) for register in "y".*map((i) -> lpad(i, 2, "0"), 0:44)], ""))
yvalue = parse(Int, ybit, base=2)
sum = xvalue + yvalue
sumbit = bitstring(sum)

@show xbit
@show xvalue
@show ybit
@show yvalue

@show sum

@show solution
@show sumbit
@show solutionbit

println("expected: ",lstrip(sumbit, '0'))
println("received: ",solutionbit)
sumbittrim = reverse(lstrip(sumbit, '0'))
for (idx, val) in enumerate(reverse(solutionbit))
    if val != sumbittrim[idx]
        println("incorrect bit " * string(idx-1))
    end
end


