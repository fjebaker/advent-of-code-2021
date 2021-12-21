using Memoization
using BenchmarkTools

struct DeterministicDice
end

mutable struct Player
    id::Int
    pos::Int
    score::Int
end

function roll!(generator)
    sum = 0
    for _ in 1:3
        sum += popfirst!(generator)
    end
    sum
end

function Base.iterate(d::DeterministicDice)
    generator = Iterators.Stateful(Iterators.cycle(1:100))
    value = roll!(generator)
    value, generator
end

function Base.iterate(d::DeterministicDice, generator)
    value = roll!(generator)
    value, generator
end

function parse_input(path)
    matches = eachmatch(r"Player (\d+) starting position: (\d+)", read(path, String))
    map(matches) do match
        i = parse.(Int, match.captures)
        Player(i[1], i[2], 0)
    end
end

function play!(player, value)
    player.pos = mod1(player.pos + value, 10)
    player.score += player.pos
end

function playgame!(players, dice)
    rollcount = 0
    for (value, player) in zip(dice, Iterators.cycle(players))
        rollcount += 3
        play!(player, value)

        player.score ≥ 1000 && break
    end
    rollcount
end

function part1(players)
    rollcount = playgame!(players, DeterministicDice())
    minscore = minimum(i -> i.score, players)
    rollcount * minscore
end

function incplayer(p, d1, d2, d3)
    np = mod1(p.pos + d1 + d2 + d3, 10)
    np, np + p.score
end

# part 2; i really guessed the wrong direction in part 1 -- should have given more attention to 
# the "dirac" part of "dirac dice"

@memoize function diracplay(player1, player2, is_player1)
    universes1 = 0
    universes2 = 0
    for dice1 in 1:3, dice2 in 1:3, dice3 in 1:3
        if is_player1
            np, ns = incplayer(player1, dice1, dice2, dice3)
            if ns ≥ 21
                universes1 += 1
            else
                u1, u2 = diracplay((pos = np, score=ns), player2, false)
                universes1 += u1
                universes2 += u2
            end
        else
            np, ns = incplayer(player2, dice1, dice2, dice3)
            if ns ≥ 21
                universes2 += 1
            else
                u1, u2 = diracplay(player1, (pos=np, score=ns), true)
                universes1 += u1
                universes2 += u2
            end
        end
    end
    universes1, universes2
end

function part2(players)
    u1, u2 = diracplay(
        (pos=players[1].pos, score=players[1].score), 
        (pos=players[2].pos, score=players[2].score),
        true 
    )
    max(u1, u2)
end



players = parse_input("day21/input.txt")

pt1 = @btime part1(p) setup = (p = deepcopy($players))
# 10.149 ns (0 allocations: 0 bytes)

pt2 = @btime part2(p) setup = (p = deepcopy($players))
# 221.837 ns (2 allocations: 96 bytes)

println("Part1: $pt1")
println("Part2: $pt2")




