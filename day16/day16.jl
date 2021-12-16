using BenchmarkTools
using Test

abstract type AbstractPacket{T} end
abstract type AbstractOperation end

struct SUM <: AbstractOperation end
struct PROD <: AbstractOperation end
struct MIN <: AbstractOperation end
struct MAX <: AbstractOperation end
struct GRT <: AbstractOperation end
struct LESS <: AbstractOperation end
struct EQ <: AbstractOperation end

const OP_MAP = Dict{Int, AbstractOperation}(
    0 => SUM(), 1 => PROD(), 2 => MIN(), 3 => MAX(), 5 => GRT(), 6 => LESS(), 7 => EQ()
)

struct LiteralValue{T} <: AbstractPacket{T}
    version::T
    value::T
end

struct Operator{V,T} <: AbstractPacket{T}
    version::T
    optype::V
    subpackets::Vector{AbstractPacket{T}}
end

function nextbit(n::T, i)::T where {T}
    (n >> (7-i)) & 0b1
end

function binarystream(string)
    tokens = (
        parse(UInt8, @view(string[i:i+1]), base=16) for i in 1:2:length(string)
    )
    Iterators.Stateful(nextbit(i, j) for j in 0:7, i in tokens)
end

decode!(itr, n) = sum(2^(n-i) * j for (i, j) in Iterators.take(enumerate(itr), n))

function readpacket!(bs, version, type::Val{4})
    # println(" + LiteralValue (v=$version)")
    values = UInt8[]
    while !isempty(bs)
        contbit = popfirst!(bs)
        # read in the values
        for _ in 1:4
            push!(values, popfirst!(bs))
        end
        if contbit == 0 # NO NEW NUMBER
            break
        end
    end
    val = decode!(values, length(values))
    LiteralValue(version, val)
end

function readop!(bs)
    length = decode!(bs, 15) + bs.taken
    numbers = AbstractPacket{Int}[]
    while bs.taken < length 
        push!(numbers, nextpacket!(bs))
    end
    numbers
end

function readop!(bs, num_packets)
    numbers = AbstractPacket{Int}[]
    for _ in 1:num_packets
        push!(numbers, nextpacket!(bs))
    end
    numbers
end

function readpacket!(bs, version, ::Val{T}) where {T}
    # println(" + Operator (v=$version) $T")
    ltype_id = popfirst!(bs)
    if ltype_id == 0 # next 15 bits are total length
        numbers = readop!(bs) 
    else
        num_packets = decode!(bs, 11)
        numbers = readop!(bs, num_packets)
    end
    Operator(version, OP_MAP[T], numbers)
end

function skippad!(bs)
    println("taken = $(bs.taken)")
    while bs.taken % 4 != 0
        popfirst!(bs)
    end
end

function nextpacket!(bs)
    version = decode!(bs, 3)
    packtype = decode!(bs, 3)
    readpacket!(bs, version, Val(packtype))
end

versionsum(p::LiteralValue) = p.version
versionsum(p::Operator) = p.version + versionsum(p.subpackets)
versionsum(packets::Vector{AbstractPacket{T}}) where {T} = sum(versionsum, packets)

@testset "Decoder Test" begin
    bs = binarystream("D2FE28")
    packet = nextpacket!(bs)
    @test packet.version == 6
    @test packet.value == 2021

    bs = binarystream("38006F45291200")
    packet = nextpacket!(bs)
    @test packet.version == 1
    @test packet.optype == LESS()
    @test packet.subpackets[1].value == 10
    @test packet.subpackets[2].value == 20

    bs = binarystream("EE00D40C823060")
    packet = nextpacket!(bs)
    @test packet.version == 7
    @test packet.optype == MAX()
    @test packet.subpackets[1].value == 1
    @test packet.subpackets[2].value == 2
    @test packet.subpackets[3].value == 3
end

@testset "Version Sum Tests" begin 
    bs = binarystream("8A004A801A8002F478")
    packet = nextpacket!(bs)
    @test versionsum(packet) == 16

    bs = binarystream("620080001611562C8802118E34")
    packet = nextpacket!(bs)
    @test versionsum(packet) == 12

    bs = binarystream("C0015000016115A2E0802F182340")
    packet = nextpacket!(bs)
    @test versionsum(packet) == 23

    bs = binarystream("A0016C880162017C3686B18A3D4780")
    packet = nextpacket!(bs)
    @test versionsum(packet) == 31
end


evaluate(v::LiteralValue) = v.value
evaluate(op::Operator{SUM}) = sum(evaluate, op.subpackets)
evaluate(op::Operator{PROD}) = prod(evaluate, op.subpackets)
evaluate(op::Operator{MIN}) = minimum(evaluate, op.subpackets)
evaluate(op::Operator{MAX}) = maximum(evaluate, op.subpackets)
function evaluate(op::Operator{GRT, T})::T where {T}
    args = evaluate.(op.subpackets)
    args[1] > args[2]
end
function evaluate(op::Operator{LESS, T})::T where {T}
    args = evaluate.(op.subpackets)
    args[1] < args[2]
end
function evaluate(op::Operator{EQ, T})::T where {T}
    args = evaluate.(op.subpackets)
    args[1] == args[2]
end
function evaluate(op)
    error("No implementation for $(typeof(op))")
end

@testset "Evaluate Operators" begin
    bs = binarystream("C200B40A82")
    @test evaluate(nextpacket!(bs)) == 3

    bs = binarystream("04005AC33890")
    @test evaluate(nextpacket!(bs)) == 54

    bs = binarystream("880086C3E88112")
    @test evaluate(nextpacket!(bs)) == 7

    bs = binarystream("CE00C43D881120")
    @test evaluate(nextpacket!(bs)) == 9

    bs = binarystream("D8005AC2A8F0")
    @test evaluate(nextpacket!(bs)) == 1

    bs = binarystream("F600BC2D8F")
    @test evaluate(nextpacket!(bs)) == 0

    bs = binarystream("9C005AC2F8F0")
    @test evaluate(nextpacket!(bs)) == 0

    bs = binarystream("9C0141080250320F1802104A08")
    @test evaluate(nextpacket!(bs)) == 1
end


function part1(bs)
    packet = nextpacket!(bs)
    versionsum(packet)
end

function part2(bs) 
    packet = nextpacket!(bs)
    evaluate(packet)
end

bs = binarystream(readline("day16/input.txt"))

@btime part1($deepcopy(bs))
# 380.909 μs (999 allocations: 48.42 KiB)

@btime part2($deepcopy(bs))
# 409.862 μs (1349 allocations: 59.20 KiB)

println("Part1: $(part1(deepcopy(bs)))")
println("Part2: $(part2(deepcopy(bs)))")

