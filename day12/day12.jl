#= 
    Using this one as an opportunity to learn the Graphs ecosystem.
=#

import Cairo, Fontconfig
using Graphs, GraphPlot, MetaGraphs
using Compose, Colors

# why are there so many graph plotting packages, and none of them are complete?

using GraphRecipes, Plots

getsize(name) = islowercase(name[1]) ? 0 : 1

function parse_input(path)
    # parse input into graph (would otherwise use dictionary to list)

    graph_map = Dict{String, Tuple{Int, Int}}("start" => (1, -1), "end" => (2, -1))
    count = 2

    connections = map(eachline(path)) do line
        nodes = split(line, '-')
        for n in nodes
            if n ∉ keys(graph_map)
                count += 1
                graph_map[n] = (count, getsize(n))
            end
        end
        (graph_map[first(nodes)][1], graph_map[last(nodes)][1])
    end

    g = MetaGraph(count) # simple graph 

    # add properties
    for (name, (i, s)) in graph_map
        set_props!(g, i, Dict(:name => name, :size => s, :visited => false))
    end

    # add connections
    for con in connections
        add_edge!(g, con[1][1], con[2][1])
    end
    g
end


function resetgraph!(g)
    for vertex in vertices(g)
        # reset all vertices to unvisited
        set_prop!(g, vertex, :visited, false)
    end
    # except for start
    set_prop!(g, 1, :visited, true)
end

# Visualisation functions 

function plotgraph(g)
    
    verts = collect(vertices(g))
    gplot(
        g,
        #loc_x,
        #loc_y,
        layout=circular_layout,
        nodelabel=[get_prop(g, i, :name) for i in verts],
        nodefillc=[get_prop(g, i, :visited) ? colorant"orange" : colorant"lightseagreen" for i in verts]
    )
end

function drawgraphs(gs...)
    n = length(gs)
    sq = ceil(sqrt(n))
    indexes = collect((i % sq, i ÷ sq) for i in 0:n)
    @show indexes
    compose(
        context(units=UnitBox(sq, sq)),
        ((context(i..., 1, 1), g) for (i, g) in zip(indexes, gs))...
    )
end

function getconn(path)
    connections = Vector{Int64}[[] for i in 1:nv(g)]

    n = length(path)
    for i in 2:n
        push!(connections[path[i-1]], path[i])
    end
    connections
end

function plotallpaths(paths)
    pathsplots = map(paths) do path 
        connections = getconn(path)
        
        graphplot(
            connections,
            nodeshape=:circle, 
            self_edge_size=0.25,
            nodecolor=:white
        )
    end

    plot(pathsplots..., size=(1200,800))
end

function getpaths(g, vertex; path=Int64[], validpaths=Vector{Int64}[])
    push!(path, vertex)
    if vertex == 2 # end vertex
        push!(validpaths, path)
        return []
    end

    for v in inneighbors(g, vertex)

        if get_prop(g, v, :visited)
            continue
        end
        
        if get_prop(g, v, :size) == 0
            # visit small cave
            set_prop!(g, v, :visited, true)

            getpaths(g, v, path=copy(path), validpaths=validpaths)

            # then forget that we've visited it for checking subsequent paths
            set_prop!(g, v, :visited, false)
        else
            getpaths(g, v, path=copy(path), validpaths=validpaths)
        end

    end

    return validpaths
end

# Problem functions 

function numpaths(g, vertex; twice = false)

    if vertex == 2 # end vertex
        return 1
    end

    paths = 0
    for v in inneighbors(g, vertex)

        if get_prop(g, v, :visited)
            if twice && v > 2
                paths += numpaths(g, v, twice=false)
            end
            continue
        end

        if get_prop(g, v, :size) == 0
            # visit small cave
            set_prop!(g, v, :visited, true)

            paths += numpaths(g, v, twice=twice)

            # then forget that we've visited it for checking subsequent paths
            set_prop!(g, v, :visited, false)
    
        else
            paths += numpaths(g, v, twice=twice)
        end
    end

    return paths
end

function part1(g)
    resetgraph!(g)
    numpaths(g, 1)
end 

function part2(g)
    resetgraph!(g)
    numpaths(g, 1, twice=true)
end 


g = parse_input("day12/input.txt")

# --- visualisation 
# set_prop!(g, 1, :visited, true)
# paths = getpaths(g, 1)
# plotallpaths(paths)

println("Part1: $(part1(g))")
println("Part1: $(part2(g))")