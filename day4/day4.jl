using BenchmarkTools

to_matrix(x) = parse.(Int, reduce(hcat, split.(x)))

function parse_input(file)
    content = [i for i in eachline(file) if i != ""] 
    numbers = parse.(Int, split(content[1], ','))
    boards = [content[i:i+4] for i in 2:5:lastindex(content)]
    numbers, to_matrix.(boards)
end

numbers, boards = parse_input("day4/input.txt")

function check_winner(board)
    @inbounds for i in 1:first(size(board))
        rowsum = sum(@view(board[i, :]))
        colsum = sum(@view(board[:, i]))
        if rowsum == -5 || colsum == -5
            return true
        end
    end
    false
end

# bingo for number i
function do_number(i, boards)
    replace!.(boards, i => -1)
    check_winner.(boards)
end

# sum only positive values
pos_sum(board) = mapreduce(i -> i > 0 ? i : 0, +, board)

function part1!(numbers, boards)
    result = 0
    for i in numbers
        winners = do_number(i, boards)
        if any(winners)
            # println("Winner found! Last number $i")
            
            winner = @views first(boards[winners])
            result = i * pos_sum(winner)
            break
        end
    end
    result
end


function part2!(numbers, boards)
    result = 0
    for i in numbers
        winners = do_number(i, boards)
        if all(winners)
            # println("Last winner found! Last number $i")
            result = i * pos_sum(boards[1])
            break 
        end
        boards = @view(boards[.~winners])
    end
    result
end


@btime part1!($numbers, $(deepcopy(boards)))
# 6.959 μs (4 allocations: 1.05 KiB)

@btime part2!($numbers, $(deepcopy(boards)))
# 5.694 μs (3 allocations: 1008 bytes)

println("Part1: $(part1!(numbers, deepcopy(boards)))")
println("Part2: $(part2!(numbers, deepcopy(boards)))")
