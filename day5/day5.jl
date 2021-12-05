using BenchmarkTools

struct Point
    x::Int64
    y::Int64
end

abstract type AbstractOrientation end
struct Straight <: AbstractOrientation end
struct Diagonal <: AbstractOrientation end

struct Line{isStraight}
    p1::Point
    p2::Point

    function Line(x1, y1, x2, y2) 
        if x1 == x2 || y1 == y2
            return new{Straight}(Point(x1, y1), Point(x2, y2))
        else
            return new{Diagonal}(Point(x1, y1), Point(x2, y2))
        end
    end

end

is_straight(l::Line{Straight}) = true
is_straight(l::Line{O}) where {O} = false
x_range(l::Line{O}) where {O} = l.p1.x ≤ l.p2.x ? range(l.p1.x,l.p2.x) : range(l.p2.x,l.p1.x)
y_range(l::Line{O}) where {O} = l.p1.y ≤ l.p2.y ? range(l.p1.y,l.p2.y) : range(l.p2.y,l.p1.y)
x_range(l::Line{Diagonal}) = l.p1.x ≤ l.p2.x ? range(l.p1.x,l.p2.x) : range(l.p1.x,l.p2.x,step=-1) 
y_range(l::Line{Diagonal}) = l.p1.y ≤ l.p2.y ? range(l.p1.y,l.p2.y) : range(l.p1.y,l.p2.y,step=-1) 

function max_extent(lines)
    x_max = 0
    y_max = 0
    for l in lines
        l.p1.x > x_max && (x_max = l.p1.x)
        l.p2.x > x_max && (x_max = l.p2.x)
        l.p1.y > y_max && (y_max = l.p1.y)
        l.p2.y > y_max && (y_max = l.p2.y)
    end
    (x_max, y_max)
end

function parse_input(path)
    map(eachline(path)) do line
        groups = match(r"(\d+),(\d+) -> (\d+),(\d+)", line)
        values = parse.(Int, groups)
        # add 1 to account for Julia indexing
        Line(values[1]+1, values[2]+1, values[3]+1, values[4]+1)
    end
end

function addline!(oceanfloor, l::Line{O}) where {O} 
    oceanfloor[x_range(l), y_range(l)] .+= 1 
end

function addline!(oceanfloor, l::Line{Diagonal}) 
    for (x, y) in Iterators.zip(x_range(l), y_range(l))
        oceanfloor[x, y] += 1 
    end
end

function part1!(oceanfloor, lines)
    for line in filter(is_straight, lines)
        addline!(oceanfloor, line)
    end
    count(≥(2), oceanfloor)
end

function part2!(oceanfloor, lines)
    for line in lines
        addline!(oceanfloor, line)
    end
    count(≥(2), oceanfloor)
end

lines = parse_input("day5/input.txt")
oceanfloor = zeros(Int, max_extent(lines) .+ 1)

@btime part1!(floor, $lines) setup = (floor = deepcopy($oceanfloor))
# 900.577 μs (653 allocations: 901.70 KiB)

@btime part2!(floor, $lines) setup = (floor = deepcopy($oceanfloor))
# i don't feel like trying to hunt performance here
# 22.482 ms (459415 allocations: 14.95 MiB)

println("Part1: $(part1!(deepcopy(oceanfloor), lines))")
println("Part2: $(part2!(deepcopy(oceanfloor), lines))")

