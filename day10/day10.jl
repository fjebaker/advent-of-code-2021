using BenchmarkTools


function parse_input(path)
    collect(eachline(path))
end

mutable struct ChunkStack
    stack::Vector{Char}
    size::Int
    sp::Int

    ChunkStack(size::Int) = new(Vector{Char}(undef, size), size, 1)
end

# part 1
const SCORE_MAP = Dict{Char, Int}(')' => 3, ']' => 57, '}' => 1197, '>' => 25137) 
# part 2
const OPEN_SCORE_MAP = Dict{Char, Int}('(' => 1, '[' => 2, '{' => 3, '<' => 4)
# bracket mappers
const OPEN_CLOSE_MAP = Dict{Char, Char}('(' => ')', '{' => '}', '[' => ']', '<' => '>')
const CLOSE_OPEN_MAP = Dict{Char, Char}(v => k for (k, v) in OPEN_CLOSE_MAP)
isopening(char) = char ∈ keys(OPEN_CLOSE_MAP)

function push!(cs::ChunkStack, item::Char)
    if cs.sp + 1 > cs.size
        error("Stack overflow.")
    end
    @inbounds cs.stack[cs.sp] = item
    cs.sp += 1
end

function pop!(cs::ChunkStack)
    if cs.sp - 1 < 1
        error("Stack underflow.")
    end
    cs.sp -= 1
    @inbounds cs.stack[cs.sp]
end

function parse!(cs::ChunkStack, line)
    score = 0
    cs.sp = 1 # reset stack
    for char in line
        if isopening(char)
            push!(cs, char)
        else
            last = pop!(cs)
            if last != CLOSE_OPEN_MAP[char]
                score = SCORE_MAP[char]
                break
            end
        end
    end
    score
end

inputs = parse_input("day10/input.txt")
cs = ChunkStack(100)

part1(cs, inputs) = sum(i -> parse!(cs, i), inputs)

function complete(cs::ChunkStack)
    mapfoldr(i -> OPEN_SCORE_MAP[i], (a, b) -> 5b + a, @view(cs.stack[1:cs.sp-1]), init=0)
end


function part2(cs, inputs)
    round(Int, median(complete(cs) for i in inputs if parse!(cs, i) == 0))
end

@btime part1($cs, $inputs)
# 59.961 μs (0 allocations: 0 bytes)

@btime part2($cs, $inputs)
# 73.452 μs (5 allocations: 1.98 KiB)

println("Part1: $(part1(cs, inputs))")
println("Part2: $(part2(cs, inputs))")



