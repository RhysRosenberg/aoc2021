import std/strutils
import std/sequtils

proc createboard(x: string): seq[seq[string]] =
    x.splitLines().map(proc(y:string):seq[string] = y.splitWhitespace())

var 
    inp: seq[string] = readFile("input.txt").split("\n\n")
    pulls: seq[string] = inp[0].split(',')
    boards: seq[seq[seq[string]]] = inp[1..^1].map(createboard)

while boards.len > 0 and pulls.len > 0:
    var mypull = pulls[0]
    pulls = pulls[1..^1]
    proc bingo_pull(pull: string): (proc(x: seq[seq[string]]): seq[seq[string]]) =
        return proc(board: seq[seq[string]]): seq[seq[string]] =
            board.map(
                proc(row: seq[string]): seq[string] = 
                    row.map(
                        proc(elem: string): string =
                            if elem == pull: "" else: elem))
    boards = boards.map(bingo_pull(mypull))
    proc check_board(board: seq[seq[string]]): bool =
        if board.any(proc(row: seq[string]): bool = row.all(proc(x: string): bool = x == "")):
            return false
        for j in 0..4:
            var cnt = 0;
            for i in 0..4:
                if board[i][j] == "":
                    cnt += 1
            if cnt == 5:
                return false
        return true
            
    var check = boards
    boards = boards.filter(check_board)

    proc flatten[T](x: seq[seq[T]]): seq[T] =
        x.foldl(a & b, newSeq[string]())
        
    if boards.len == 0:
        var lastboard: seq[seq[string]] = check[0]
        var nums = lastboard.flatten()
        echo nums.foldl(a + (if b != "": b.parseInt else: 0), 0) * mypull.parseInt