import std/sequtils
import std/strutils
const part = 1
var 
    inp = readFile("input.txt").split(',').map(parseInt)

var m = 1000000000000000
for x in 0..inp.max():
    proc triangle(i:int): int = 
        var dist = abs(i - x) 
        int(dist * (dist + 1) / 2)
    var test = if part == 1: 
            inp.map(proc(i:int):int = abs(i - x)).foldl(a + b, 0)
        else:
            inp.map(triangle).foldl(a + b, 0)

    m = min(test, m)
echo m
