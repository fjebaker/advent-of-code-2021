using BenchmarkTools

crabs = parse.(Int, split(readline("day7/input.txt"), ','))

medianpos(crabs) = convert(Int, median(crabs))
fuelneeded(crabs, pos) = sum(i -> abs(i-pos), crabs)

part1(crabs) = fuelneeded(crabs, medianpos(crabs))

fuelneededpoly(crabs, pos) = sum(crabs) do crab
    n = abs(crab - pos)
    n * (n+1) ÷ 2
end

function part2(crabs)
    #minimum(map(i -> fuelneededpoly(crabs, i), range(minimum(crabs), maximum(crabs))))
    minfuel = typemax(Int)
    for i in range(minimum(crabs), maximum(crabs))
        fuel = fuelneededpoly(crabs, i)
        if fuel < minfuel
            minfuel = fuel
        end
    end
    minfuel
end


@btime part1($crabs)
# 1.994 μs (1 allocation: 7.94 KiB)

@btime part2($crabs)
# 947.155 μs (0 allocations: 0 bytes)

println("Part1: $(part1(crabs))")
println("Part1: $(part2(crabs))")
