import std/strutils
import std/json
import std/math
import std/sequtils

type
    SnailfishType = enum snBranch, snLeaf
    SnailfishNumber = ref object
        kind: SnailfishType
        left: SnailfishNumber
        right: SnailfishNumber
        parent: SnailfishNumber
        val: int

proc `$`(sn: SnailfishNumber): string = 
    case sn.kind:
    of snBranch:
        result.add "["
        result.add $sn.left
        result.add " "
        result.add $sn.right
        result.add "]"
    of snLeaf:
        result = $sn.val

proc parseSnailfish(s: string): SnailfishNumber =
    proc recurseConstruct(j: JsonNode): SnailfishNumber =
        case j.kind:
        of JArray:
            result = SnailfishNumber(kind: snBranch,
                                    left: recurseConstruct(j[0]),
                                    right: recurseConstruct(j[1]))
        of JInt:
            result = SnailfishNumber(kind: snLeaf,
                                    val: j.getInt())
        else: discard
    
    result = recurseConstruct(parseJson(s))

    proc setParents(sn: SnailfishNumber, parent: SnailfishNumber, first: bool=true) =
        if not first:
            sn.parent = parent
        if sn.kind == snBranch:
            setParents(sn.left, sn, false)
            setParents(sn.right, sn, false)
    
    setParents(result, result)


proc reduceSnailfish(sn: SnailfishNumber): SnailfishNumber =
    # First, try to explode
    # Then, try to split
    # If we get to the end of the tree with no exploding or splitting, done
    discard




# ----------------------

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
        
let test = """
[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
"""
import sugar
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