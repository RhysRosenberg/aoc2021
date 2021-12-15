import std/sequtils
import std/strutils
import std/heapqueue
import std/sets
import sugar

const part = 2
let 
    input: seq[seq[int]] = 
        when part == 1:
            readFile("input.txt")
                .splitLines()
                .filterIt(it.len > 0)
                .mapIt(it.toSeq.mapIt(it.int - '0'.int))
        else:
            const firstrow = readFile("input.txt")
                .splitLines()
                .filterIt(it.len > 0)
                .mapIt(it.toSeq.mapIt(it.int - '0'.int))
                .mapIt(collect(for i in 0..4: it.mapIt((it - 1 + i) mod 9 + 1)).concat())
            collect(for i in 0..4: firstrow.mapIt(it.mapIt((it - 1 + i) mod 9 + 1))).concat()
    ymax = input.len - 1
    xmax = input[0].len - 1
#for row in input: echo input
type 
    Coord = tuple[x: int, y: int]
    Branch = object
        c: Coord
        cost: int
        predecessor: Coord

proc heuristic(c: Coord): int = 
    return ymax - c.y + xmax - c.x

proc `<`(a, b: Branch): bool = a.cost + a.c.heuristic < b.cost + b.c.heuristic
proc neighbors(c: Coord): seq[Coord] =
    @[(c.x-1, c.y), (c.x, c.y+1), (c.x+1, c.y), (c.x, c.y-1)]
        .filterIt(it[0] >= 0 and it[0] <= xmax and it[1] >= 0 and it[1] <= ymax)

var 
    branchStack: HeapQueue[Branch]
    current: Coord = (0, 0)
    visited: HashSet[Coord]

branchStack.push(Branch(c: current, cost: 0))

while true:
    #discard stdin.readLine()
    let job = branchStack.pop()
    visited.incl(job.c)
    #echo "At ", job.c, " with cost ", job.cost
    if job.c == (xmax, ymax):
        echo job.cost
        break
    else:
        #echo "far away = ", job.c.heuristic()
        #echo "neighbors are ", job.c.neighbors()
        for coord in job.c.neighbors():
            # Add all coords around to the branchStack
            if coord != job.predecessor and not visited.contains(coord):
                #echo "adding ", coord
                branchStack.push(Branch(c: coord,
                                        cost: job.cost + input[coord.y][coord.x],
                                        predecessor: job.c))