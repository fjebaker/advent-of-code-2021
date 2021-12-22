using BenchmarkTools

struct Region
    state::Bool
    x::Tuple{Int,Int}
    y::Tuple{Int,Int}
    z::Tuple{Int,Int}
end

const NULL_REGION = Region(0, (0,0), (0,0), (0,0))

volume(r::Region) = abs(
    (r.x[2] + 1 - r.x[1]) * (r.y[2] + 1 - r.y[1]) * (r.z[2] + 1 - r.z[1])
)

getoverlaps(r, regions) = unique!([
    i for i in (r ∩ other for other in regions) if i != NULL_REGION
])

function makeregion(match)
    ranges = parse.(Int, match.captures[2:end])
    Region(
        match[1] == "on",
        (ranges[1], ranges[2]),
        (ranges[3], ranges[4]),
        (ranges[5], ranges[6])
    )
end

function parse_input(path)
    matches = eachmatch(
        r"(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)",
        read(path, String)
    )
    makeregion.(matches)
end

function getoverlap(t1, t2)
    low = max(t2[1], t1[1])
    high = min(t2[2], t1[2])
    if low ≤ high
        return (low, high)
    end
    (0, 0)
end

getoverlap(r1::Region, r2::Region) = (
    getoverlap(r1.x, r2.x), getoverlap(r1.y, r2.y), getoverlap(r1.z, r2.z)
)

function Base.intersect(r1::Region, r2::Region)
    x, y, z = getoverlap(r1, r2)
    # if it doesn't overlap, or they are both "off" states
    if x == (0, 0) || y == (0, 0) || z == (0, 0)
        return NULL_REGION
    end
    Region(r2.state, x, y, z)
end

function total_volume(regions)
    if isempty(regions)
        return 0
    end

    region = popfirst!(regions)

    overlaps = getoverlaps(region, regions)

    return volume(region) + total_volume(regions) - total_volume(overlaps)
end


function countlit(regions)
    if isempty(regions)
        return 0
    end

    region = popfirst!(regions)

    if region.state == 0
        return countlit(regions)
    end

    overlaps = getoverlaps(region, regions)

    return volume(region) + countlit(regions) - total_volume(overlaps)
end

function part1(regions)
    mask = Region(1, (-50, 50), (-50, 50), (-50, 50))
    subregions = getoverlaps(mask, regions)
    countlit(subregions)
end

function part2(regions)
    countlit(regions)
end



regions = parse_input("day22/input.txt")

pt1 = @btime part1(rs) setup = (rs = deepcopy($regions))
# 3.431 ms (68216 allocations: 13.34 MiB)

pt2 = @btime part2(rs) setup = (rs = deepcopy($regions))
# 1.341 ms (24308 allocations: 4.75 MiB)


println("Part1: $pt1")
println("Part2: $pt2")
