import std/strutils
import std/sequtils
import std/sets
import std/tables
import std/strformat
import std/algorithm
import sugar

const
    part = 2
    inp: seq[seq[int]] = readFile("input.txt")
    .splitLines()
    .mapIt(it.toSeq.mapIt(it.int - '0'.int))
    rowlen = len(inp)
    collen = len(inp[0])
if part == 1:
    var cnt = 0
    for rowi in 0..<rowlen:
        for coli in 0..<collen:
            if (coli == 0 or inp[rowi][coli] < inp[rowi][coli-1]) and 
            (coli == collen - 1 or inp[rowi][coli] < inp[rowi][coli+1]) and
            (rowi == 0 or inp[rowi][coli] < inp[rowi - 1][coli]) and
            (rowi == rowlen - 1 or inp[rowi][coli] < inp[rowi + 1][coli]):
                cnt += 1 + inp[rowi][coli]
    echo cnt
else:
    type coord = tuple[x: int, y: int]
    var 
        stack: seq[coord]
        left_to_check: HashSet[coord]
        basinmap: Table[coord, int]
    
    proc at[T](map: seq[seq[T]], c: coord): T =
        map[c.y][c.x]
    
    for i in 0..<collen:
        for j in 0..<rowlen:
            left_to_check.incl((i, j))
    
    var ticker=0
    while left_to_check.len > 0:
        var c = left_to_check.pop()
        if inp.at(c) != 9: ticker += 1 # New region
        stack.add(c)
        while stack.len > 0:
            # Flood from the stack top
            var c = stack.pop()
            if basinmap.contains(c):
                # Skip it if we already have it
                continue
            else:
                basinmap[c] = ticker
                left_to_check.excl(c)
            if inp.at(c) == 9:
                # This is a wall, don't flood past this, and in fact add it to the basin map
                basinmap[c] = -1
                continue
            if c.x > 0:
                stack.add((c.x-1, c.y))
            if c.x < collen - 1:
                stack.add((c.x+1, c.y))
            if c.y > 0:
                stack.add((c.x, c.y-1))
            if c.y < rowlen - 1:
                stack.add((c.x, c.y+1))
            
    var uniqueBasins: CountTable[int]
    for x in basinmap.values:
        uniqueBasins.inc(x)
    echo uniqueBasins

    var myseq: seq[int]
    for (i, x) in uniqueBasins.pairs:
        if i != -1:
            myseq.add(x)
    
    myseq.sort()
    echo myseq
    echo myseq[^3..^1]
    echo myseq[^3..^1].foldl(a * b, 1)
    