
lights_map = Dict()
brightness_map = Dict()

function add_brightness(light)
    brightness_map[light] = get(brightness_map, light, 0) + 1
end

function add_brightness_more(light)
    brightness_map[light] = get(brightness_map, light, 0) + 2
end

function dim(light)
    brightness = get(brightness_map, light, 0)
    if brightness > 0
        brightness_map[light] = brightness -= 1
    end
end

function toggle(light)
    lights_map[light] = get(lights_map, light, 0) ⊻ 1
end

function turn_on(light)
    lights_map[light] = 1
end

function turn_off(light)
    if (haskey(lights_map, light))
        lights_map[light] = 0
    end
end

function get_ranges(line)
   (lx, ly, rx, ry) = map((number) -> parse(Int, number), match(r".* (\d+),(\d+) through (\d+),(\d+)", line).captures)

   ((lx, rx), (ly, ry))
end

function parse_line(line)
    switch = get_switch(line)
    ranges = get_ranges(line)

    (ranges, switch)
end

function parse_line_2(line)
    switch = get_bright_switch(line)
    ranges = get_ranges(line)

    (ranges, switch)
end

function get_switch(line)
    if occursin(r"turn on.*", line)
        return turn_on
    elseif occursin(r"turn off.*", line)
        return turn_off
    elseif occursin(r"toggle.*", line)
        return toggle
    else
        throw("wrong command")   
    end
end

function get_bright_switch(line)
    if occursin(r"turn on.*", line)
        return add_brightness
    elseif occursin(r"turn off.*", line)
        return dim
    elseif occursin(r"toggle.*", line)
        return add_brightness_more
    else
        throw("wrong command")   
    end
end

function run_commands(commands)
    for (((lx,rx), (ly, ry)), switch) in commands
        for x in lx:rx
           for y in ly:ry
               switch((x,y))
           end
       end
   end
end

f = open(joinpath(@__DIR__, "input.txt"), "r")
lines = readlines(f)
close(f)

commands = map(parse_line, lines)

function solution1()
    commands = map(parse_line, lines)
    run_commands(commands)
    size(collect(Iterators.filter((elem) -> elem == 1, values(lights_map))))[1]
end

function solution2()
    commands = map(parse_line_2, lines)
    run_commands(commands)
    sum(collect(Iterators.filter((elem) -> elem > 0, values(brightness_map))))
end

println("solution1: ", solution1())
println("solution2: ", solution2())
