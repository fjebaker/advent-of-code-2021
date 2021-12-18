using Test

using Combinatorics
using BenchmarkTools
using JSON

import Base.:+

mutable struct ShellfishNumber
    l::Union{ShellfishNumber, Int}
    r::Union{ShellfishNumber, Int}
end

Base.:+(s1::ShellfishNumber, s2::ShellfishNumber) = ShellfishNumber(s1, s2)

Base.:(==)(s1::ShellfishNumber, s2::ShellfishNumber) = s1.l == s2.l && s1.r == s2.r
Base.:(==)(s::ShellfishNumber, i::Int) = false

Base.show(io::IO, s::ShellfishNumber) = write(io, "[$(s.l), $(s.r)]")

toshellfish(v::Int) = v
toshellfish(v) = ShellfishNumber(toshellfish(first(v)), toshellfish(last(v)))
toshellfish(s::String) = toshellfish(JSON.parse(s))

function parse_input(path)
    toshellfish.(eachline(path))
end

function walkends(s::ShellfishNumber)
    if typeof(s.r) == typeof(s.l) == Int
        return (s,)
    elseif typeof(s.l) == Int && typeof(s.r) == ShellfishNumber
        return (s, walkends(s.r)...)
    elseif typeof(s.r) == Int && typeof(s.l) == ShellfishNumber
        return (walkends(s.l)..., s)
    end
    (walkends(s.l)..., walkends(s.r)...)
end

function getexploding(s::ShellfishNumber; depth=0, parent=nothing)
    if depth ≥ 4 && s.l isa Int && s.r isa Int
        return (depth, parent, s)
    end

    node = s.l isa Int ? (nothing, nothing, nothing) : getexploding(s.l, depth=depth+1, parent=s)
    if !isnothing(node[1])
        return node
    end
    node = s.r isa Int ? (nothing, nothing, nothing) : getexploding(s.r, depth=depth+1, parent=s)
    return node
end

function passleft!(s, v)
    if typeof(s.r) == Int
        s.r += v
    else
        s.l += v
    end
end

function passright!(s, v)
    if typeof(s.l) == Int
        s.l += v
    else
        s.r += v
    end
end

explodeone!(s) = explode!(s, one=true)

function explode!(s; one=false)
    exploded = false

    (depth, parent, leaf) = getexploding(s)
    while !isnothing(depth)      
        # assemble layout of endpoints
        layout = collect(walkends(s))

        # find which node we are
        i = first(i for (i, n) in enumerate(layout) if n === leaf)

        # propagate left and right values
        i - 1 ≥ 1 && passleft!(layout[i-1], leaf.l)
        i + 1 ≤ length(layout) && passright!(layout[i+1], leaf.r)

        if parent.l === leaf
            parent.l = 0
        else
            parent.r = 0
        end

        exploded = true

        if exploded && one
            break
        end
        (depth, parent, leaf) = getexploding(s)
    end
    (s=s, changed=exploded)
end

function split!(v::Int)
    v > 9 ? (ShellfishNumber(floor(Int, v/2), ceil(Int, v/2)), true) : (v, false)
end
function split!(s::ShellfishNumber)
    (s.l, m) = split!(s.l)
    if m
        return (s=s, changed=true)
    end
    (s.r, m) = split!(s.r)
    (s=s, changed=m)
end

function reduce!(s)
    i = 0
    while explode!(s).changed || split!(s).changed
        # @show s
        i += 1
        if i > 1000
            error("too many loops")
        end
    end
    (s=s, changed= i > 0)
end

@testset "Explodes" begin
    sf = toshellfish("[[[[[9,8],1],2],3],4]")
    explodeone!(sf)
    @test sf == toshellfish("[[[[0,9],2],3],4]")

    sf = toshellfish("[7,[6,[5,[4,[3,2]]]]]")
    explodeone!(sf)
    @test sf == toshellfish("[7,[6,[5,[7,0]]]]")

    sf = toshellfish("[[6,[5,[4,[3,2]]]],1]")
    explodeone!(sf)
    @test sf == toshellfish("[[6,[5,[7,0]]],3]")

    sf = toshellfish("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]")
    explodeone!(sf)
    @test sf == toshellfish("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]") 

    sf = toshellfish("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
    explodeone!(sf)
    @test sf == toshellfish("[[3,[2,[8,0]]],[9,[5,[7,0]]]]")
end

@testset "Operations" begin
    sf = toshellfish("[11, 2]")
    split!(sf)
    @test sf == toshellfish("[[5, 6], 2]")

    sf1 = toshellfish("[[[[4,3],4],4],[7,[[8,4],9]]]")
    sf2 = toshellfish("[1,1]")
    sf3 = sf1 + sf2 

    @test sf3 == toshellfish("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]")
    reduce!(sf3)
    @test sf3 == toshellfish("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")
end

@testset "Summations & Reductions" begin
    nums = toshellfish.(["[1,1]", "[2,2]", "[3,3]", "[4,4]"])
    @test (sum(nums)) == toshellfish("[[[[1,1],[2,2]],[3,3]],[4,4]]")

    sf = toshellfish("[[[[0, [4, 5]], [0, 0]], [[[4, 5], [2, 6]], [9, 5]]], [7, [[[3, 7], [4, 3]], [[6, 3], [8, 8]]]]]")
    @test reduce!(sf).s == toshellfish("[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]")
end

function magnitude(sf::ShellfishNumber)
    left = 3 * (sf.l isa Int ? sf.l : magnitude(sf.l))
    right = 2 * (sf.r isa Int ? sf.r : magnitude(sf.r))
    return left + right
end

function part1(nums)
    sum = nums[1]
    for i in nums[2:end]
        sum = reduce!(sum + i).s
    end
    magnitude(sum)
end

function part2(nums)
    f(x,y) = magnitude(reduce!(deepcopy(x + y)).s)
    maximum(max(f(s1, s2), f(s2, s1)) for (s1, s2) in combinations(nums, 2))
end

function benchmark(s1in, s2in)
    s1 = deepcopy(s1in)
    s2 = deepcopy(s2in)
    println("Addition")
    s3 = @btime +($s1, $s2)
    println("Collect Walk")
    @btime collect(walkends($s3))
    println("Explode")
    s4 = @btime explode!($deepcopy($s3))
    s5 = s4.s
    println("Split")
    @btime split!($deepcopy($s5))
end


nums1 = parse_input("day18/input.txt")
nums2 = deepcopy(nums1)

p1 = @btime part1(n) setup = (n = deepcopy(nums1))
# 2.487 ms (37052 allocations: 1.12 MiB)

p2 = @btime part2(n) setup = (n = deepcopy(nums2))
# 507.431 ms (4519414 allocations: 141.37 MiB)


println("Part1: $p1")
println("Part2: $p2")



