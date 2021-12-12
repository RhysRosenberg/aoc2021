import std/sequtils
import std/strutils

var f: File
discard f.open("input.txt")
var s: string = f.readAll()
var sseq = s.splitLines()

var part1 = false

const MAXSIZE = 1000
var arr = repeat(repeat(0, MAXSIZE), MAXSIZE)

proc tocoord(s:string): seq[int] =
    s.split(',').map(parseInt)

for inp in sseq:
    var
        pieces = inp.split(" -> ").map(tocoord)
        a = pieces[0]
        b = pieces[1]
        xdir = if a[0] != b[0]: ((b[0] - a[0]) / abs(b[0] - a[0])).toInt else: 0
        ydir = if a[1] != b[1]: ((b[1] - a[1]) / abs(b[1] - a[1])).toInt else: 0
    
    if part1 and ydir != 0 and xdir != 0:
        continue
    arr[a[1]][a[0]] += 1
    while a != b:
        a[0] += xdir
        a[1] += ydir
        arr[a[1]][a[0]] += 1

var cnt = 0

for subl in arr:
    for x in subl:
        if x > 1:
            cnt += 1
echo(cnt)

    