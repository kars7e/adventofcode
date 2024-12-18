

function nice1(line)
    banned = ["ab", "cd", "pq", "xy"]
    vowels = "aeiou"
    char_in_row = false
    vowel = 0
    if line[1] in vowels
        vowel += 1
    end
    for seq in zip(line, line[2:end])
        if join(seq) in banned
            return false
        end
        if seq[1] == seq[2]
            char_in_row = true
        end
        if seq[2] in vowels
            vowel += 1
        end
    end
    char_in_row && vowel > 2
end

function nice2(line)
    seen = Dict()
    in_seen = false
    in_seen_seq = Nothing
    has_same_letters = false
    letters_seq = Nothing
    for (idx, seq) in enumerate(zip(line[1:end], line[2:end]))
        if haskey(seen, seq)
            if get(seen, seq, -1) != idx - 1
                in_seen = true
                in_seen_seq = seq
            end
        else
            seen[seq] = idx
        end
    end

    for seq in zip(line[1:end], line[2:end], line[3:end])
        if seq[1] == seq[3]
            has_same_letters = true
            letters_seq = seq
        end
    end
    if in_seen && has_same_letters
        @show line, in_seen_seq, letters_seq
    end
    in_seen && has_same_letters
end

f = open(joinpath(@__DIR__, "input.txt"), "r")
lines = readlines(f)
close(f)

println("solution1: ", size(filter(identity, map(nice1, lines)))[1])
println("solution2: ", size(filter(identity, map(nice2, lines)))[1])