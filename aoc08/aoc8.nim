import std/sequtils
import std/strutils
import std/tables
import std/sets
import std/math

# WARNING: HERE BE DRAGONS

const part = 2
var 
    input = readFile("input.txt").splitLines()

var signalpatterns = input.map(proc(x:string):seq[string] = x.split(" | ")[0].split(" "))
var outputs = input.map(proc(x:string):seq[string] = x.split(" | ")[1].split(" "))

if part == 1:
    var cnt = 0
    for suboutputs in outputs:
        proc closure(x: string): bool = x.len in @[2, 4, 3, 7]
        cnt += suboutputs.filter(closure).len
    echo cnt
else:
    var total: int = 0
    var answertbl = initTable[HashSet[char], int]()
    var oneswires, fourwires, lshape: HashSet[char]
    for t in zip(signalpatterns, outputs):
        var 
            signalpattern = t[0]
            output = t[1]
        for signal in signalpattern:
            case signal.len:
                of 2:
                    answertbl[signal.toHashSet] = 1
                    oneswires = signal.toHashSet
                of 3:
                    answertbl[signal.toHashSet] = 7
                of 4:
                    answertbl[signal.toHashSet] = 4
                    fourwires = signal.toHashSet
                of 7:
                    answertbl[signal.toHashSet] = 8
                else:
                    discard
        lshape = fourwires - oneswires
            # Now program a constraint solver lol
        proc lenchecker(desired_len: int): (proc(x: string): bool) = 
            return proc(x: string): bool = 
                return x.len == desired_len
        var horizontals: HashSet[char]
        for signal in signalpattern.filter(lenchecker(5)):
            var x = signal.toHashSet
            if oneswires < x:
                answertbl[signal.toHashSet] = 3
                horizontals = x - oneswires
            elif lshape < x:
                answertbl[signal.toHashSet] = 5
            else:
                answertbl[signal.toHashSet] = 2
        for signal in signalpattern.filter(lenchecker(6)):
            var x = signal.toHashSet
            if oneswires < x and horizontals < x:
                answertbl[signal.toHashSet] = 9
            elif oneswires < x:
                answertbl[signal.toHashSet] = 0
            else:
                answertbl[signal.toHashSet] = 6
        
        echo(answertbl)

        for i in 0..3:
            total += answertbl[output[i].toHashSet] * (10 ^ (3-i))
    echo total
