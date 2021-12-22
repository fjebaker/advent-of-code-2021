struct Region
    state::Int
    x::Tuple{Int, Int}
    y::Tuple{Int, Int}
    z::Tuple{Int, Int}
end

function makeregion(match)
    state = match[1] == "on" ? 1 : 0
    ranges = parse.(Int, match.captures[2:end])
    Region(
        state,
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



function get_overlap(t1, t2)
    if overlaps(t1, t2)
        high = min(t2[2], t1[2])
        low = max(t2[1], t1[1])
        return (low, high)
    end
    (0, 0)
end

function Base.intersect(r1::Region, r2::Region)
    x = get_overlap(r1.x, r2.x)
    y = get_overlap(r1.y, r2.y)
    z = get_overlap(r1.z, r2.z)
    # if it doesn't overlap, or they are both "off" states
    if x == (0, 0) || y == (0, 0) || z == (0, 0) || r1.state == r2.state == 0
        return NULL_REGION
    end
    Region(r2.state, x, y, z)
end

function addoverlap!(ons, toremove, overlaps)
    region = first(overlaps)
    for other in overlaps[2:end]
        overlap = region ∩ other
        if overlap != NULL_REGION
end

function calculate(regions)
    toremove = Region[]
    ons = Region[]

    for (i, r) in enumerate(regions)
        ons_copy = copy(ons)
        toremove_copy = copy(toremove)

        # check if overlaps any of the previous
        overlaps = Region[]
        for other in ons_copy
            overlap = r ∩ other
            if overlap != NULL_REGION
                push!(overlaps, overlap)
            end
        end
        addoverlap!(ons, toremove, overlaps)

        if r.state == 1
            println("adding $r to ons")
            push!(ons, r)
            println(" => $ons")
        end

        println()
    end

    #sum(volume, ons)
    toremove, ons
end


regions = parse_input("day22/test_large.txt")

r = Region(1, (0, 5), (0, 5), (0, 5))
r2 = Region(1, (0, 6), (0, 5), (0, 5))

println("*"^50)
remove, ons = calculate((r, r, r))

length(remove), length(ons)

#calculate(regions)
