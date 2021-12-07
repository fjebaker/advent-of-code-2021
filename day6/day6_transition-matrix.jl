using BenchmarkTools
using StaticArrays

# precomputed transition matrix
const S_TRANS_MATRIX = @SMatrix([
    0 1 0 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0;
    0 0 0 1 0 0 0 0 0;
    0 0 0 0 1 0 0 0 0;
    0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 1 0 0;
    1 0 0 0 0 0 0 1 0;
    0 0 0 0 0 0 0 0 1;
    1 0 0 0 0 0 0 0 0
])

function parse_fish(path)
    # slight variation from first method
    living = zeros(Int, 9)
    open(path) do io
        fish = parse.(Int, split(readline(io), ','))
        for f in fish
            living[f+1] += 1
        end
    end
    living
end

function evolvedays(fish, days)
    sum((S_TRANS_MATRIX^days) * fish)
end

fish = parse_fish("day6/input.txt")

part1(fish) = evolvedays(fish, 80)
part2(fish) = evolvedays(fish, 256)

@btime part1(fish)
@btime part2(fish)

println("Part1: $(part1(fish))")
println("Part2: $(part2(fish))")