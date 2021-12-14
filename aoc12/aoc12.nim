<<<<<<< HEAD
import std/sequtils
import std/strutils

const input = readFile("test.txt").splitLines()

    
=======
import std/strutils
import std/sequtils
import std/tables
import std/sets
import sugar

let input = readFile("input.txt").splitLines().map((x) => x.split('-')).filterIt(it.len > 1)
const part = 2

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

var allpaths: seq[string]
proc countPaths(g: Table[string, Node], l: string, visited: HashSet[string], doubledon: string = "", path: var seq[string]): int = 
  #echo "We have entered into ", l, " with links ", g[l].links, " and we doubled on ", doubledon
  var myp = path
  myp.add(l)
  if l == "end":
    allpaths.add(myp.foldl(a & "," & b))
    return 1 # If we reached the end, This is one path
  var newVisited = visited # Copy the visited set so we can modify it
  if l.allIt(it.isLowerAscii()):
    # If the cave is small
    newVisited.incl(l)
  # The paths are all links that were not already visited
  let 
    paths = g[l].links.filterIt(not visited.contains(it))
    visitedpaths = g[l].links.filterIt(visited.contains(it))
  var extra = 0
  if part == 2 and doubledon == "":
    # We are testing part 2 and we are not in a doubled-fork
    # Count the paths going into that doubled-up small cave
    extra = visitedpaths
      .filterIt(it != "start" and it != "end")
      .mapIt(g.countPaths(it, newVisited, it, myp)).foldl(a + b, 0)
  if paths.len == 0:
    # If there are no paths out of here and we haven't reached the end, there are 0 paths on this branch
    return 0
  # Count all the paths leading out of the paths, and then add them all up 
  return paths.mapIt(g.countPaths(it, newVisited, doubledon, myp)).foldl(a + b, 0)

var h = initHashSet[string]() 
var s = newSeq[string]()
echo "part1: ", cavesystem.countPaths("start", h, "", s)
echo "part2: ", allpaths.len
>>>>>>> 14a14b5925bb77d115e5c758e5e0e60a1950b90b
