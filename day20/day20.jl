function parse_input(path)
    key, gridstrings = split(replace(read(path, String), '.'=>0, '#'=>1), "\n\n")
    key = parse.(Int, collect(key))
    grid = parse.(Int, reduce(hcat, collect.(split(gridstrings, '\n'))))
    key, grid
end

embedgrid!(big_grid, grid) = big_grid[2:end-1, 2:end-1] .= grid

function padfill(mat, i)
    out = fill(i, size(mat) .+2)
    embedgrid!(out, mat)
    out
end

function setpaddingto!(grid, i)
    grid[:, 1] .= i
    grid[:, end] .= i
    grid[1, :] .= i
    grid[end, :] .= i
end

decodecell(cell) = sum(2^(9-i) * v for (i,v) in enumerate(cell))

function convolve(grid, key, prevpad, nextpad)
    big_grid = padfill(grid, prevpad)
    grid = padfill(grid, nextpad)

    height, width = size(big_grid)
    for i in 2:width-1, j in 2:height-1
        s = @views decodecell(big_grid[j-1:j+1, i-1:i+1])
        grid[j, i] = key[s+1]
    end
    grid
end

function displaygrid(grid)
    height, width = size(grid)
    for i in 1:width
        for j in 1:height
            c = grid[j, i] == 1 ? '#' : '.'
            print("$c")
        end
        println()
    end
end

function evolve!(grid, key, days)
    grid = zeropad(grid)
    defaults = (key[1], key[1] == 1 ? key[end] : key[1])
    for i in 1:days
        pp = i%2==0 ? defaults[1] : defaults[2] 
        np = i%2==0 ? defaults[2] : defaults[1] 
        grid = convolve(grid, key, pp, np)
    end
    grid
end

key, grid = parse_input("day20/input.txt")

part1(grid, key) = count(>(0), evolve!(grid, key, 2))
part2(grid, key) = count(>(0), evolve!(grid, key, 50))

pt1 = part1(deepcopy(grid), key)
pt2 = part2(deepcopy(grid), key)

println("Part1: $pt1")
println("Part2: $pt2")