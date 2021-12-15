using UnicodePlots
using BenchmarkTools

# a* search algorithm
struct AStarState{F}
    f::Vector{Int}
    g::Vector{Int}
    h::F
    open::Vector{Int}
    parents::Vector{Int}

    function AStarState(size; heuristic::F=(n) -> 0) where {F}
        init = fill(typemax(Int), size) 
        new{F}(init, copy(init), heuristic, Int[], zeros(Int, size))
    end

end

function poplowest!(state) 
    ind = argmin(state.f[i] for i in state.open)
    popat!(state.open, ind)
end

function getneighbours(i, row_size, max_index)
    (j for j in (i - 1, i + 1, i + row_size, i - row_size) 
        if (1 ≤ j ≤ max_index) && (
            j == (i-1) ? (i - 1) % row_size != 0 
        :   j == (i+1) ? (i + 1) % row_size != 1
        : true)
    )
end

function a_star_converge!(state::AStarState{F}, weights, target) where {F}
    # need maximum dimensions
    row_size = first(size(weights))
    max_index = lastindex(weights)
    # setup
    push!(state.open, 1)
    state.f[1] = state.h(1)
    state.g[1] = 0

    # search
    while !isempty(state.open)
        current = poplowest!(state)
        if current == target
            return true
        end

        for nbr in getneighbours(current, row_size, max_index)
            try_g = state.g[current] + weights[nbr]
            if try_g < state.g[nbr]
                # path is better
                state.parents[nbr] = current
                state.g[nbr] = try_g
                state.f[nbr] = try_g + state.h(nbr)
                
                if nbr ∉ state.open
                    push!(state.open, nbr)
                end
            end
        end

    end

    false
end

function reconstruct(state::AStarState{F}, curr::Int) where {F}
    path = Int[curr]
    while curr != 1
        curr = state.parents[curr]
        push!(path, curr)
    end
    reverse!(path)
end

function a_star_grid!(state::AStarState{F}, weights, target)::Vector{Int} where {F}
    if a_star_converge!(state, weights, target)
        return reconstruct(state, target)
    end
    Int[]
end

costpath(path, weights) = sum(weights[i] for i in path) - weights[1]

function enlarge(cave)
    increment(x, i) = (x+i) % 9 == 0 ? 9 : (x+i) % 9 
    bigger_cave = reduce(hcat, (increment.(cave, i-1) for i in 1:5))
    reduce(vcat, (increment.(bigger_cave, i-1) for i in 1:5))
end

function part1(state, cave)
    path = a_star_grid!(state, cave, lastindex(cave)) 
    costpath(path, cave)
end

function part2(state, cave)
    path = a_star_grid!(state, cave, lastindex(big_cave))
    costpath(path, cave)
end


cave = parse.(Int, reduce(hcat, collect.(eachline("day15/input.txt"))))
big_cave = enlarge(cave)

state = AStarState(length(cave))
state2 = AStarState(length(big_cave))

@btime part1($deepcopy(state), $cave)
# 2.510 ms (23 allocations: 250.19 KiB)

@btime part2($deepcopy(state2), $big_cave)
# 228.187 ms (28 allocations: 5.80 MiB)

println("Part1: $(part1(state, cave))")
println("Part2: $(part2(state2, big_cave))")