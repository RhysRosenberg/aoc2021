import std/strutils
import std/tables
import std/sequtils
const
    part = 2
    days = if part == 1: 80 else: 256
var 
    lanternfish = readFile("input.txt").split(',').map(parseInt)
    fishtbl = initTable[int, int]()

for x in 0..8:
    fishtbl[x] = 0
for x in lanternfish:
    fishtbl[x] += 1
for i in 1..days:
    var spawners = fishtbl[0]
    for x in 1..8:
        fishtbl[x-1] = fishtbl[x]

    fishtbl[8] = spawners
    fishtbl[6] += spawners

echo toSeq(fishtbl.values).foldl(a + b, 0)