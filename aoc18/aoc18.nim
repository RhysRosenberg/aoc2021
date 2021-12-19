import std/strutils
import std/math
import std/sequtils

type 
    SNDigit = tuple[val: int, depth: int]
    SNNumber = seq[SNDigit]

proc parseSN(s: string): SNNumber =
    var depth = 0
    for c in s:
        if c == '[':
            depth += 1
        elif c == ']':
            depth -= 1
        elif c.isDigit: 
            result.add (val: c.int-'0'.int, depth: depth)

proc reduceSN(sn: SNNumber): SNNumber = 
    var sn = sn
    var i = 0
    var explodesDone: bool = false
    while i < sn.len:
        if sn[i].depth > 4 and i+1 < sn.len and sn[i+1].depth > 4:
            #echo sn.mapIt(it.val)
            #echo "Exploding [", sn[i], ",", sn[i+1], "]"
            # Regular number that is explodable
            let left = sn[i].val
            # Move left and add to the first found number
            if i-1 >= 0:
                sn[i-1].val += left
            let right = sn[i+1].val
            if i+2 < sn.len:
                sn[i+2].val += right
            sn[i] = (val: 0, depth: sn[i].depth-1)
            sn.delete(i+1) # Delete the next of the pair
            i = 0
            continue
        if explodesDone and sn[i].val >= 10:
            explodesDone = false
            #echo sn.mapIt(it.val)
            # Split the number
            let splitval: float = sn[i].val / 2
            #echo "Splitting ", sn[i].val, " into ", splitval.floor.toInt, " and ", splitval.ceil.toInt
            sn[i].val = splitval.floor.toInt
            sn[i].depth += 1
            sn.insert((val: splitval.ceil.toInt, depth: sn[i].depth), i+1)
            i = 0
            continue
        i += 1
        if i == sn.len and not explodesDone:
            # Loop again looking for splits
            explodesDone = true
            i = 0
    return sn

proc `+`(a, b: SNNumber): SNNumber =
    result = a & b
    for x in result.mitems:
        x.depth += 1
    result = reduceSN(result)

proc magnitude(sn: SNNumber): int =
    var sn = sn
    while sn.len > 1:
        for i in 0..<sn.len-1:
            if sn[i].depth == sn[i+1].depth:
                sn[i].depth -= 1
                sn[i].val = 3*sn[i].val + 2*sn[i+1].val
                sn.delete(i+1)
                break
    sn[0].val
        
const part = 2
when part == 1:
    echo readFile("input.txt")
        .splitLines()
        .filterIt(it.len > 0)
        .map(parseSN)
        .foldl(a + b)
        .magnitude()
else:
    let input = readFile("input.txt").splitLines().filterIt(it.len > 0)
    var max: int
    for i in 0..<input.len:
        for j in 0..<input.len:
            if i != j:
                let x = (input[i].parseSN + input[j].parseSN).magnitude
                if x > max: max = x
    echo max

