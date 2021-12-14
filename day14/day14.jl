import DataStructures: DefaultDict

function parse_input(path)
    polymer, relations = split(read(path, String), "\n\n")
    # create dict mapping
    mapping = Dict{String,String}()
    for i in eachmatch(r"(\w+) -> (\w+)", relations)
        mapping[i[1]] = i[2]
    end
    
    return polymer, mapping
end

function substitute!(p, mapping)
    for (pair, count) in copy(p)
        if haskey(mapping, pair)
            new_char = mapping[pair]
            p[pair] -= count
            p[pair[1]*new_char] += count
            p[new_char*pair[2]] += count
        end
    end
end

function countchars(p)
    counts = DefaultDict{Char, Int}(0)
    for (k, v) in p
        counts[k[2]] += v
    end
    counts
end


function countafter(polymer, mapping; days=10)
    # parse into pair counts
    pairs = DefaultDict{String, Int}(0)
    for i in 2:length(polymer)
        p1 = @view(polymer[i-1:i])
        pairs[p1] += 1
    end
    # do the replacements
    for i in 1:days
        substitute!(pairs, mapping)
    end
    counts = countchars(pairs)
    counts[polymer[1]] += 1
    abs(-(extrema(values(counts))...))
end


polymer, mapping = parse_input("day14/input.txt")

part1(polymer, mapping) = countafter(polymer, mapping, days=10)
part2(polymer, mapping) = countafter(polymer, mapping, days=40)

part2(polymer, mapping)
