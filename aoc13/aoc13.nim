import std/strutils
import std/sequtils
import std/strscans
import std/sets

const part = 2

let 
  input = readFile("input.txt").split("\n\n")
  coords = input[0].splitLines
  folds = input[1].splitLines.filterIt(it.len > 0)

type Coord = tuple[x: int, y: int]

var
  paper: HashSet[Coord]

paper.incl(coords.mapIt(it.split(',').map(parseInt)).mapIt(cast[Coord]((it[0], it[1]))).toHashSet)

discard """
var output: array[20, array[20, char]]

for row in output.mitems:
  for x in row.mitems:
    x = '.'

for coord in paper.items:
  output[coord.y][coord.x] = '#'

for row in output:
  echo row.join(" ")
  """

for fold in folds:
  if part == 1 and fold != folds[0]:
    break
  var
    direction: char
    axis: int
  discard fold.scanf("fold along $c=$i", direction, axis)
  case direction:
    of 'y':
      let toofar = paper.toSeq.filterIt(it.y > axis)
      paper.incl(toofar.mapIt((it.x, 2*axis - it.y)).toHashSet)
      paper.excl(toofar.toHashSet)
    of 'x':
      let toofar = paper.toSeq.filterIt(it.x > axis)
      paper.incl(toofar.mapIt((2*axis - it.x, it.y)).toHashSet)
      paper.excl(toofar.toHashSet)
    else:
      discard

if part == 1: echo paper.toSeq.len

if part == 2:
  var output: array[10, array[100, char]]
  for i in 0..9:
    for j in 0..99:
      output[i][j] = ' '
  for p in paper.items:
    output[p.y][p.x] = '#'
  for row in output.items:
    echo row.join(" ")
    
