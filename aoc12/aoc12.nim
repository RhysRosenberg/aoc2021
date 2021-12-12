import std/strutils
import std/sequtils
import std/tables
import std/sets
import sugar

let input = readFile("input.txt").splitLines().map((x) => x.split('-')).filterIt(it.len > 1)
const part = 1

type 
  Node = ref object
    links: seq[string]

var cavesystem: Table[string, Node]

proc applier(it: seq[string]) = 
    var n0 = cavesystem.mgetOrPut(it[0], new(Node))
    var n1 = cavesystem.mgetOrPut(it[1], new(Node))
    n0.links.add(it[1])
    n1.links.add(it[0])

input.apply(applier)

proc countPaths(g: Table[string, Node], l: string, visited: var HashSet[string]): int = 
  if l == "end":
    return 1
  var newVisited = visited
  if l.allIt(it.isLowerAscii()):
    newVisited.incl(l)
  let 
    n = g[l]
    paths = n.links.filterIt(not visited.contains(it))
  if paths.len == 0:
    return 0
  return paths.mapIt(g.countPaths(it, newVisited)).foldl(a + b, 0)

var h = initHashSet[string]() 
echo cavesystem.countPaths("start", h)

