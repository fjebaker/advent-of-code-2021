using BenchmarkTools

# parse input into a matrix of numbers
numbers = parse.(Int, 
    hcat(
        collect.(
            eachline("day3/input.txt")
        )...
    )
)

# utility function 
to_number(x) = parse(Int, String(vec(convert.(UInt8, x) .+ '0')), base=2)

function part1(numbers)
    gamma = mean(numbers, dims=2) .> 0.5
    epsilon = .~gamma
    to_number(gamma) * to_number(epsilon)
end

function filternumbers(numbers, i, cmp)
    row = @view(numbers[i, :])

    # common bit
    # use slightly under 0.5 to ensure picks 1 over 0
    cb = cmp(mean(row), 0.499999)

    selection = row .== cb
    new_selection = @view(numbers[:, selection])

    # check if we only have one number left
    if size(new_selection)[2] == 1
        return new_selection
    else
        return filternumbers(new_selection, i+1, cmp)
    end
end

o2rating(numbers) = filternumbers(numbers, 1, >)
co2scrubber(numbers) = filternumbers(numbers, 1, <)

function part2(numbers)
    to_number(o2rating(numbers)) * to_number(co2scrubber(numbers))
end

p1_res = @btime part1($numbers)
# 7.893 μs (23 allocations: 1.42 KiB)

p2_res = @btime part2($numbers)
# 19.552 μs (91 allocations: 58.80 KiB)

println("Part1: $(p1_res)")
println("Part2: $(p2_res)")