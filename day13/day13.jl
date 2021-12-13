
function parse_input(path)
    points = Tuple{Int, Int}[]
    itt = eachline(path)
    x_max = 0
    y_max = 0
    for i in itt
        i == "" && break
        x, y = parse.(Int, split(i, ",")) .+ 1
        x > x_max && (x_max = x)
        y > y_max && (y_max = y)
        push!(points, (x, y))
    end
    folds = map(itt) do i
        m = match(r"fold along (\w)=(\d+)", i)
        (ax=m[1][1], i=parse(Int, m[2]) + 1)
    end

    paper = zeros(Int, (y_max, x_max))
    for (x, y) in points
        paper[y, x] = 1  
    end

    paper, folds
end

function foldalong_x(mat, xi)
    x_end = xi-1
    output = mat[:, 1:x_end]
    output[:, x_end:(-1):1] += mat[:, (xi+1):end]
end

function foldalong_y(mat, yi)
    y_end = yi-1
    output = mat[1:y_end, :]
    output[y_end:(-1):1, :] += mat[(yi+1):end, :]
end

function foldalong(mat, axis, index)
    if axis == 'y'
        # provide a rotated view of matrix
        return foldalong_y(mat, index)
    else
        return foldalong_x(mat, index)
    end
    
end

function display(mat)
    height, width = size(mat)
    for j in height:-1:1
        for i in 1:width
            v = mat[j, i] > 0 ? '#' : '.'
            print("$v")
        end
        println()
    end
end

function part1(paper, folds)
    first_fold = first(folds)
    folded = foldalong(paper, first_fold[1], first_fold[2])
    count(>(0), folded)
end
paper, folds = parse_input("day13/input.txt")

function part2(paper, folds)
    folded = copy(paper)
    for (axis, i) in folds
        folded = foldalong(folded, axis, i)
    end
    folded
end

#part1(paper, folds)

#folded = part2(paper, folds)
#display(folded)


foldx(paper, x) = paper[:, 1:x-1] += paper[:, end:-1:x+1]
foldy(paper, y) = paper[1:y-1, :] += paper[end:-1:y+1, :]

#folded = reduce(foldpaper, folds; init=paper)
# display(folded)


# parsing
toint(s) = parse(Int, s) + 1
points, folds = split.(split(read("day13/input.txt", String), "\n\n"), '\n')
points = map(i -> tuple(toint.(split(i, ','))...), points)
# assemble points on paper
paper = zeros(Int, (maximum(first, points), maximum(last, points)))
paper[map(CartesianIndex, points)] .+= 1

# do the folding 
foldx(paper, x) = @inbounds paper[:, 1:x-1] += @view(paper[:, end:-1:x+1])
foldy(paper, y) = @inbounds paper[1:y-1, :] += @view(paper[end:-1:y+1, :])
foldpaper(paper, f) = 'y' ∈ f[1] ? foldx(paper, toint(f[2])) : foldy(paper, toint(f[2]))

part2(paper, folds) = mapreduce(i -> match(r"(\w)=(\d+)", i), foldpaper, folds; init=paper)

@btime part2($paper, $folds)
;

