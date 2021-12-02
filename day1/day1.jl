using BenchmarkTools

file = "day1/input.txt"
values = parse.(Int, eachline(file))

function part1(values)
    count(1:lastindex(values)) do i
        @inbounds values[i] < values[i+1]
    end
end

function part2(values)
    count(1:lastindex(values)-3) do i
        # exploit mathematics of the problem 
        # just compare every 4th value
        @inbounds values[i] < values[i+3]
    end
end

@btime part1($values)
# 368.485 ns (0 allocations: 0 bytes)
println("Part 1: $(part1(values))")

@btime part2($values)
# 189.950 ns (0 allocations: 0 bytes)
println("Part 2: $(part2(values))")
