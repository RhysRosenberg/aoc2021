import std/sequtils
import std/strutils
import std/tables

const part = 2

type Pair = tuple[key: string, val: char]
proc toPair(l: seq[string]): Pair =
    assert l.len == 2
    result.key = l[0]
    result.val = l[1][0]

let
    input = readFile("input.txt").split("\n\n")
    polymer_template = input[0].zip(input[0][1..^1]).mapIt($(it[0]) & $(it[1]))
    pair_insertion_rules: Table[string, char] = input[1].splitLines().filterIt(it.len > 0).mapIt(it.split(" -> ").toPair()).toTable()

var 
    polymer: CountTable[string] # This will count the number of pairs of atoms in the string
    letternums: CountTable[char]

for p in input[0]:
    letternums.inc(p)

for p in polymer_template:
    polymer.inc(p)

const num_reps = if part == 1: 10 else: 40
for rep in 1..num_reps:
    var newpolymer = polymer
    for x in polymer.keys.toSeq:
        if pair_insertion_rules.hasKey(x):
            let bridge = pair_insertion_rules[x]
            let newPairs = @[$(x[0]) & $(bridge), $(bridge) & $(x[1])]
            echo x, " to ", newpairs
            let numold = polymer[x]
            letternums.inc(bridge, numold)
            for p in newPairs:
                newpolymer.inc(p, numold)
            newpolymer.inc(x, -numold)
    polymer = newpolymer
echo letternums.largest[1] - letternums.smallest[1]