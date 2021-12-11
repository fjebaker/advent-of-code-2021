using BenchmarkTools
import StatsBase: countmap

heightmap = parse.(Int, reduce(hcat, collect.(eachline("day9/input.txt"))))

function localmins!(output, row)
    lasti = lastindex(row)
    # check first and last
    @inbounds output[1] &= row[1] < row[2]
    @inbounds output[end] &= row[end] < row[end-1]
    # check bulk
    for i in 2:lasti-1
        @inbounds output[i] &= row[i] < row[i-1] && row[i] < row[i+1]
    end
end

function findminima(heightmap)
    # allocate output array
    localmins = BitArray(undef, size(heightmap)) 
    localmins .= 1

    # rows
    for (o, i) in Iterators.zip(eachrow(localmins), eachrow(heightmap))
        localmins!(o, i)
    end
    
    # columns
    for (o, i) in Iterators.zip(eachcol(localmins), eachcol(heightmap))
        localmins!(o, i)
    end

    localmins
end

function part1(heightmap)
    minima = findminima(heightmap)
    sum((heightmap[i] + 1 for i in eachindex(heightmap) if minima[i]))
end

function floodfill!(heightmap, value, i, j)
    (heightmap[j, i] == 9 || heightmap[j, i] < 0) && return
    height, width = size(heightmap)
    
    @inbounds heightmap[j, i] = value
    # flood left
    i > 1 && floodfill!(heightmap, value, i - 1, j)
    # flood right
    i < width && floodfill!(heightmap, value, i + 1, j)
    # flood down
    j > 1 && floodfill!(heightmap, value, i, j - 1)
    # flood up
    j < height && floodfill!(heightmap, value, i, j + 1)
end

function part2(heightmap)
    # source values
    minima = findminima(heightmap)
    # identifier value for each basin
    value = -1
    height, width = size(heightmap)

    for i in 1:width, j in 1:height
        if minima[j, i]

            floodfill!(heightmap, value, i, j)

            value -= 1
        end
    end

    prod(@view(sort([v for (k, v) in countmap(vec(heightmap)) if k < 0], rev=true)[1:3]))
end

@btime part1($heightmap)
# 104.827 μs (2 allocations: 1.38 KiB)

@btime part2(hm) setup = (hm = deepcopy(heightmap))
# 306.908 μs (29 allocations: 115.77 KiB)

println("Part1: $(part1(heightmap))")
println("Part2: $(part2(heightmap))")
