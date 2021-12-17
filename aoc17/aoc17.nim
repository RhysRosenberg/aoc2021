import std/strscans
import std/sets

const part = 2
let input = readFile("input.txt")

let (success, xbegin, xend, ybegin, yend) = scanTuple(input, "target area: x=$i..$i, y=$i..$i")

var possibleXspeeds: seq[int]
var initspeed: int = 1
while initspeed <= xend:
    var pos = 0
    var speed = initspeed
    while speed > 0:
        pos += speed
        speed -= 1
        if pos in xbegin..xend:
            possibleXspeeds.add(initspeed)
            break
    initspeed += 1

initspeed = 1
when part == 1:
    var maxHeight: int = 0
else:
    var possibleSpeeds: HashSet[tuple[x: int, y: int]]

for xspeed in possibleXspeeds:
    # Run the simulation with Y values as well
    for initspeed in -1000..1000:
        #echo "SPEEDS: ", xspeed, " ", initspeed
        # Initspeed checking loop
        var cv = (x: xspeed, y: initspeed)
        var c = (x: 0, y: 0)
        while c.x <= xend and c.y >= ybegin:
            #echo c
            # While it's within both bounds, and is not stationary:
            c.x = c.x + cv.x
            c.y = c.y + cv.y
            cv.x = max(cv.x - 1, 0)
            cv.y = cv.y - 1
            if c.x in xbegin..xend and c.y in ybegin..yend:
                when part == 1:
                    let newheight = ((initspeed * (initspeed+1)) / 2).toInt
                    if newheight > maxHeight:
                        echo "new max height ", newheight
                        echo "with ", xspeed, " and ", initspeed
                        maxHeight = newheight
                        break
                else:
                    possibleSpeeds.incl (xspeed, initspeed)

when part == 1:
    echo maxHeight 
else:
    echo possibleSpeeds.len
