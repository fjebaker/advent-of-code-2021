using BenchmarkTools

function parse_fish(path)
    living = zeros(Int, 10)
    open(path) do io
        fish = parse.(Int, split(readline(io), ','))
        for f in fish
            living[f+2] += 1
        end
    end
    living
end

daymod(day) = day % 10 + 1

function evolveday!(living, day)
    i0 = daymod(day)
    i6 = daymod(day + 7)
    i8 = daymod(day + 9)

    living[i6] += living[i0]
    living[i8] += living[i0]
    living[i0] = 0
end

function part1(living)
    for i in 1:80
        evolveday!(living, i)
    end
    sum(living)
end

function part2(living)
    for i in 1:256
        evolveday!(living, i)
    end
    sum(living)
end

living = parse_fish("day6/input.txt")

@btime part1(inp) setup = (inp = deepcopy(living))
# 369.252 ns (1 allocation: 16 bytes)

@btime part2(inp) setup = (inp = deepcopy(living))
# 1.122 μs (1 allocation: 16 bytes)

println("Part1: $(part1(deepcopy(living)))")
println("Part2: $(part2(deepcopy(living)))")