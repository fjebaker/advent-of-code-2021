using BenchmarkTools

struct TargetArea
    x::UnitRange{Int}
    y::UnitRange{Int}
end

Base.in((x, y), t::TargetArea) = x ∈ t.x && y ∈ t.y

struct ProjectilePath
    target::TargetArea
    xv::Int
    yv::Int
end

nextvel(xv, yv) = (xv > 0 ? xv - 1 : 0, yv - 1)
Base.iterate(pp::ProjectilePath) = (x=0, y=0), (0, 0, pp.xv, pp.yv)
function Base.iterate(pp::ProjectilePath, (x, y, xv, yv))
    # check bounds
    if x > pp.target.x.stop || y < pp.target.y.start
        return nothing
    end
    x += xv
    y += yv
    (x=x, y=y), (x, y, nextvel(xv, yv)...)
end

function findmaxheight(target, xv, yv)
    maxheight = 0
    for p in ProjectilePath(target, xv, yv)
        if p.y > maxheight
            maxheight = p.y
        end
        if p ∈ target
            return maxheight
        end
    end
    0
end

function part1(target)
    maximum(findmaxheight(target, x, y) for x in 1:500, y in 1:500)
end

function hitstarget(target, xv, yv)::Bool
    for p in ProjectilePath(target, xv, yv)
        if p ∈ target
            return true
        end
    end
    false
end

function part2(target)
    count(
        hitstarget(target, x, y) for x in -500:500, y in -500:500
    )
end

test_target = TargetArea(20:30, -10:-5)
target = TargetArea(175:227, -134:-79)

@btime part1($target)
# 5.511 ms (0 allocations: 0 bytes)

@btime part2($target)
# 111.357 ms (0 allocations: 0 bytes)

println("Part1: $(part1(target))")
println("Part2: $(part2(target))")
        