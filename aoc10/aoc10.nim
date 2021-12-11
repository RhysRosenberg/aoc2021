import std/math
import std/sequtils
import std/strutils
import sugar
import std/tables
import std/algorithm

const
    part = 2
    lines = readFile("input.txt").splitLines()
    lookup = {
        '[': ']',
        '{': '}',
        '<': '>',
        '(': ')'
    }.toTable
    p1_points = {
        ')': 3,
        ']': 57,
        '}': 1197,
        '>': 25137
    }.toTable
    p2_points = {
        '(': 1,
        '[': 2,
        '{': 3,
        '<': 4
    }.toTable


if part == 1:
    var total_points = 0
    for line in lines:
        var stack: seq[char]
        for c in line.items:
            if c in @['[', '{', '(', '<']:
                stack.add(c)
            else:
                var o = stack.pop()
                if lookup[o] != c:
                    # Corrupted, report
                    echo "corrupted: ", line
                    total_points += p1_points[c]
                    continue
    echo total_points
else:
    var total_points = 0
    var points_vector: seq[int]
    for line in lines:
        var stack: seq[char]
        var ignorethis = false
        for c in line.items:
            if c in @['[', '{', '(', '<']:
                stack.add(c)
            else:
                var o = stack.pop()
                if lookup[o] != c:
                    # Corrupted, ignore this line
                    ignorethis = true
                    break
        if ignorethis:
            continue
        var line_pointval = 0
        while stack.len > 0:
            var popped = stack.pop()
            var pointval = p2_points[popped]
            line_pointval *= 5
            line_pointval += pointval
        points_vector.add(line_pointval)
    
    points_vector.sort()
    echo points_vector[toInt(math.floor(points_vector.len / 2))]

    discard