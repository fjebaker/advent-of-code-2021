using BenchmarkTools

instructions = collect(eachline("day2/input.txt"))

function part1(instructions)
    depth = 0
    pos = 0

    for i in instructions
        v = parse(Int, last(i))
        d = first(i)

        if d == 'u'
            depth -= v
        elseif d == 'd'
            depth += v
        else
            pos += v
        end
    end

    depth * pos
end


@btime part1(instructions)
# 14.776 μs (1 allocation: 16 bytes)

println("Part1 = $(part1(instructions))")


function part2(instructions)
    depth = 0
    pos = 0
    aim = 0

    for i in instructions
        v = parse(Int, last(i))
        d = first(i)

        if d == 'u'
            aim -= v
        elseif d == 'd'
            aim += v
        else
            pos += v
            depth += v * aim
        end
    end

    depth * pos
end


@btime part2(instructions)
# 15.284 μs (1 allocation: 16 bytes)

println("Part2 = $(part2(instructions))")