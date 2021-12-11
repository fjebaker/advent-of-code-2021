using BenchmarkTools


parse_input(path) = parse.(Int, reduce(hcat, collect.(eachline(path))))

function flash!(grid, flashed, col, row)
    width, height = size(grid)

    @inbounds for i in row-1:row+1, j in col-1:col+1

        if i < 1 || i > width || j < 1 || j > height
            continue
        end

        # add to surrounding 
        grid[j, i] += 1

        # check if caused surrounding to flash that haven't already flashed
        if grid[j, i] > 9 && flashed[j, i] == 0
            flashed[j, i] = 1
            flash!(grid, flashed, j, i)
        end

    end
end

function cycleday!(grid, flashed)
    width, height = size(grid)

    # increment by 1
    grid .+= 1

    # find those which will flash
    @inbounds for j in 1:height, i in 1:width
        if grid[j, i] > 9 && flashed[j, i] == 0
            flashed[j, i] = 1
            flash!(grid, flashed, j, i)
        end
    end

    # set everyone who flashed to 0
    @inbounds for j in 1:height, i in 1:width
        if flashed[j, i]
            grid[j, i] = 0
        end
    end

    flash_count = sum(flashed)

    # reset flashed
    flashed .= 0

    flash_count
end

function part1!(grid, flashed)
    flash_count = 0
    for day in 1:100
        flash_count += cycleday!(grid, flashed)
    end
    flash_count
end

function part2!(grid, flashed)
    flash_count = 0
    day = 0
    while flash_count != 100
        day += 1
        flash_count = cycleday!(grid, flashed)
    end
    day
end


grid = parse_input("day11/input.txt")

flashed = BitArray(undef, size(grid))
flashed .= 0


@btime part1!(g, $flashed) setup = (g = deepcopy($grid))
# 81.592 μs (0 allocations: 0 bytes)

@btime part2!(g, $flashed) setup = (g = deepcopy($grid))
# 36.713 μs (0 allocations: 0 bytes)

println("Part1: $(part1!(deepcopy(grid), flashed))")
println("Part2: $(part2!(deepcopy(grid), flashed))")