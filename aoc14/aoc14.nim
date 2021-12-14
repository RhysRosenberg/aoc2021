import std/sequtils
import std/strutils
import std/tables

const part = 4

type Pair = tuple[key: string, val: char]
proc toPair(l: seq[string]): Pair =
    assert l.len == 2
    result.key = l[0]
    result.val = l[1][0]

let
    input = readFile("input.txt").split("\n\n")
    polymer_template = input[0].toSeq
    pair_insertion_rules: Table[string, char] = input[1].splitLines().filterIt(it.len > 0).mapIt(it.split(" -> ").toPair()).toTable()

const num_reps = if part == 1: 10 else: 40
var polymer = polymer_template
var toInsert: OrderedTable[int, char]
for rep in 1..num_reps:
    toInsert.clear()
    for i in 0..<polymer.len-1:
        let pair = $(polymer[i]) & $(polymer[i+1])
        if pair_insertion_rules.hasKey(pair):
            let insertchar = pair_insertion_rules[pair]
            toInsert[i+1] = insertchar
    var offset = 0
    for pair in toInsert.pairs:
        polymer.insert(pair[1], pair[0] + offset)
        offset += 1

#if part == 1:
var resultTable: CountTable[char] 
for c in polymer:
    resultTable.inc(c)

echo resultTable
let smallest = resultTable.smallest()[1]
echo smallest
let largest = resultTable.largest()[1]
echo largest
echo largest - smallest