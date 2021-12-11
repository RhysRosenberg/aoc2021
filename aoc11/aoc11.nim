import std/sequtils
import std/strutils
import std/strformat
import std/sugar

const 
    part = 2
    input = readFile("input.txt").splitLines()

type 
    Octopus = ref object of RootObj
        energy: int
        hasflashed: bool
    Octogrid = array[10, array[10, Octopus]]
    Coord = tuple[x: int, y: int]

var 
    grid: Octogrid
    flashes: int = 0

proc incenergy(o: var Octopus) = 
    o.energy += 1

for i in 0..<grid.len:
    for j in 0..<grid[i].len:
        grid[i][j] = new(Octopus)
        grid[i][j].energy = input[i][j].int - '0'.int

proc print_grid(grid: Octogrid) =
    for row in grid:
        for x in row:
            stdout.write &"""{x.energy:<4}"""
        stdout.write "\n"

proc `+`(c1: Coord, c2: Coord): Coord =
    (c1.x + c2.x, c1.y + c2.y)

const moves: seq[Coord] = block: 
    var result: seq[Coord] = @[]
    for i in -1..1:
        for j in -1..1:
            if not (i == 0 and j == 0):
                result.add (i, j)
    result

proc in_bounds(grid: Octogrid, c: Coord): bool =
    c.x >= 0 and c.y >= 0 and c.y < grid.len and c.x < grid[c.y].len

proc update(grid: Octogrid, c: Coord) =
    var x = grid[c.y][c.x]
    if not x.hasflashed:
        if x.energy > 9:
            # Flash!
            x.hasflashed = true
            flashes += 1
            for c2 in moves:
                let target = c + c2
                if grid.in_bounds(target):
                    var o = grid[target.y][target.x]
                    o.incenergy()
                    grid.update(target)

proc cleanup(grid: Octogrid) =
    for i in 0..<grid.len:
        for j in 0..<grid[i].len:
            var o = grid[i][j]
            if o.hasflashed:
                o.energy = 0
            o.hasflashed = false

proc flatten(s: Octogrid): seq[int] =
    result = @[]
    for subl in s:
        for item in subl: 
            result.add(item.energy)


if part == 1:
    for step in 1..100:
        for i in 0..<grid.len:
            for j in 0..<grid[i].len:
                grid[j][i].incenergy
        for i in 0..<grid.len:
            for j in 0..<grid[i].len:
                grid.update((j, i))
        grid.cleanup
    echo "part1: ", flashes
else:
    var allflashstep: int
    for step in 1..1000:
        for i in 0..<grid.len:
            for j in 0..<grid[i].len:
                grid[j][i].incenergy
        for i in 0..<grid.len:
            for j in 0..<grid[i].len:
                grid.update((j, i))
        grid.cleanup
        if flatten(grid).foldl(a + b, 0) == 0:
            allflashstep = step
            break
    echo "part2: ", allflashstep