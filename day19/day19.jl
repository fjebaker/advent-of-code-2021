using LinearAlgebra

using BenchmarkTools
using Combinatorics

struct Scanner
    id::Int
    data::Matrix{Int}
    diffmap::Dict{Int, Tuple{Int, Int}}
end

numvecs(s::Scanner) = size(s.data)[2]

function makescanner(string)
    id = parse(Int, match(r"--- scanner (\d+) ---", string)[1])
    data = reduce(hcat,
        (   # add dimension to make it homogenous
            [parse.(Int, match(r"(-?\d+),(-?\d+),(-?\d+)", i).captures)..., 1]
            for i in split(string, '\n')[2:end]
        )
    )

    diffmap = Dict(normsqmap(data, i1, i2) for (i1, i2) in combinations(1:size(data)[2], 2))
    Scanner(id, data, diffmap)
end

# input parser
parse_input(path) = makescanner.(split(read(path, String), "\n\n"))

# norm squared
normsq(v) = sum(v.^2)
normsqmap(data, i1, i2) = @views normsq(data[:, i2] - data[:, i1]) => (i1, i2)

shared_diffs(s1::Scanner, s2::Scanner) = collect(i for i in keys(s1.diffmap) if i in keys(s2.diffmap))

# find which vectors are in common
shared_vecs(s1::Scanner, s2::Scanner) = shared_vecs(s1, s2, shared_diffs(s1, s2))
function shared_vecs(s1::Scanner, s2::Scanner, shared_diffs)
    vecs1 = BitVector(undef, numvecs(s1))
    vecs2 = BitVector(undef, numvecs(s2))

    @inbounds for k in shared_diffs
        for i in s1.diffmap[k]
            vecs1[i] = true
        end
        for i in s2.diffmap[k]
            vecs2[i] = true
        end
    end

    # copy results so they can be modified (e.g. ordering)
    s1.data[:, vecs1], s2.data[:, vecs2]
end

# ensures vectors in vecs2 are in the same order as vecs1 by comparing to squared norms
# relative to a fixed refence vector
@views function reorder!(vecs2, vecs1)
    diffmap = Dict(normsq(v - vecs2[:, 1]) => copy(v) for v in eachcol(vecs2))

    ref_index = 1
    i = 1
    @inbounds while i ≤ size(vecs1)[2]
        nsq = normsq(vecs1[:, i] - vecs1[:, ref_index])
        if nsq in keys(diffmap)
            vecs2[:, i] .= diffmap[nsq]
        else
            ref_index += 1
            i = 0
        end
        i += 1
    end
    vecs2
end

# solve A x = b for x, to find transformation from one scanner to another
# rounds to nearest integer
function solvexfm(from_coords, to_coords)
    xfm = from_coords' \ to_coords'
    round.(Int, xfm')
end

function findxfms(scanners)
    xfms = Dict(1=>diagm(ones(Int, 4)))
    N = length(scanners)

    while length(xfms) != N
        for i in 1:N, j in 2:N
            if i == j || j ∈ keys(xfms) || i ∉ keys(xfms)
                continue
            end
            scanner_i = scanners[i]
            scanner_j = scanners[j]
            shared = shared_diffs(scanner_i, scanner_j)
            if length(shared) > 10
                # get vectors
                vecs_i, vecs_j = shared_vecs(scanner_i, scanner_j, shared)
                # reorder
                reorder!(vecs_j, vecs_i)
                # calculate xfm back to reference
                m = solvexfm(vecs_j, vecs_i)
                m .= xfms[i] * m
                # store
                xfms[j] = m
            end
        end
    end

    xfms
end

mapxfm(m, s::Scanner) = [m * v for v in eachcol(s.data)]

# find unique beacons
function part1(scanners)
    xfms = findxfms(scanners)
    vecs = reduce(vcat, mapxfm(m, scanners[k]) for (k, m) in xfms)
    length(Set(vecs))
end

manhattan(v1, v2) = sum(abs.(v2 - v1))

# find all coordinates, and then manhattan distance
function part2(scanners)
    xfms = findxfms(scanners)

    # translation (position) is last column
    pos = Dict(k=>m[1:3, end] for (k, m) in xfms)

    maximum(manhattan(pos[i], pos[j]) for (i, j) in combinations(1:length(scanners), 2))
end

scanners = parse_input("day19/input.txt")

pt1 = @btime part1($scanners)
# 2.904 ms (5297 allocations: 3.73 MiB)

pt2 = @btime part2($scanners)
# 3.094 ms (6854 allocations: 3.65 MiB)

println("Part1: $pt1")
println("Part2: $pt2")
