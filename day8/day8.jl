using BenchmarkTools

function parse_input(path)
    trials = split.(eachline(path), '|')
    map(trials) do i
        data = split.(i, ' ', keepempty=false)
        (inputs=first(data), outputs=last(data))
    end
end

function part1(data)
    lengths = (length(j) for j in Iterators.flatten(i.outputs for i in data))
    count(i -> 2 ≤ i ≤ 4 || i == 7, lengths)
end

getfirst(array, cond) = first(i for i in array if cond(i))

function decode(data)
    digit = Dict{Int, Set{Char}}()
    # sort
    
    pool = Set.(sort(data.inputs, by=length))

    # known segments
    digit[1] = pool[1]
    digit[7] = pool[2]
    digit[4] = pool[3]
    digit[8] = pool[end]

    # set operations
    digit[3] = getfirst(pool, i -> length(i) == 5 && length(i ∩ digit[7]) == 3)
    digit[6] = getfirst(pool, i -> length(i) == 6 && length(i ∩ digit[1]) == 1)
    
    digit[5] = getfirst(pool, i -> length(i) == 5 && length(i ∩ digit[6]) == 5)
    digit[9] = getfirst(pool, i -> length(i) == 6 && length(i ∩ digit[3]) == 5)

    digit[2] = getfirst(pool, i -> length(i) == 5 && i != digit[3] && i != digit[5])
    digit[0] = getfirst(pool, i -> length(i) == 6 && i != digit[6] && i != digit[9])

    outputset = Set.(data.outputs)
    sum(k * 10^(4-pos) for (k, v) in digit, (pos, number) in enumerate(outputset) if (v == number))
end

function part2(data)
    sum(decode.(data))
end

data = parse_input("day8/input.txt")

@btime part1($data)
# 9.370 μs (0 allocations: 0 bytes)

@btime part2($data)
# can't be bothered to hunt performance here again
# 1.345 ms (24725 allocations: 1.79 MiB)

println("Part1: $(part1(data))")
println("Part2: $(part2(data))")