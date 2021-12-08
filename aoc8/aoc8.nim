import std/sequtils
import std/strutils
import std/tables
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
    var answertbl = initTable[string, seq[int]]()
    for signalpattern in signalpatterns:
        for signal in signalpattern:
            case signal.len:
                of 2:
                    answertbl[signal] = @[1]
                of 3:
                    answertbl[signal] = @[7]
                of 4:
                    answertbl[signal] = @[4]
                of 5:
                    answertbl[signal] = @[2,3,5]
                of 6:
                    answertbl[signal] = @[6,9]
                of 7:
                    answertbl[signal] = @[8]
                else:
                    "impossible"