using BenchmarkTools

instructions = collect(eachline("day2/input.txt"))

function part1(instructions)
    depth = 0
    pos = 0

    for i in instructions
        v = parse(Int, last(i))
        d = first(i)
        d == 'u' && (depth -= v)
        d == 'd' && (depth += v)
        d == 'f' && (pos += v)
    end

    depth * pos
end


@btime part1(instructions)
# 9.534 μs (1 allocation: 16 bytes)

println("Part1 = $(part1(instructions))")


function part2(instructions)
    depth = 0
    pos = 0
    aim = 0

    for i in instructions
        v = parse(Int, last(i))
        d = first(i)
        d == 'u' && (aim -= v)
        d == 'd' && (aim += v)
        d == 'f' && (pos += v; depth += v * aim)
    end

    depth * pos
end


@btime part2(instructions)
# 14.921 μs (1 allocation: 16 bytes)

println("Part2 = $(part2(instructions))")