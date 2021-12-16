import std/macros
import std/strutils

const test1 = "D2FE28" #Literal
const test2 = "C200B40A82" #2 subpackets summed
const test3 = "9C0141080250320F1802104A08"

proc parseBITSproc(s: string, i: var int): NimNode =
    let packet_version = s[i..<i+3].parseBinInt()
    i+=3
    let packet_type = s[i..<i+3].parseBinInt()
    i+=3
    #echo "VERSION:", packet_version, " TYPE ", packet_type, " LEN ", s.len
    case packet_type:
        of 4:
            # literal
            #echo "LITERAL"
            var packet_data: string
            while s[i] != '0':
                # While we haven't hit the end packet
                # Consume packet data
                packet_data.add s[i+1..<i+5]
                i += 5
            # Now handle last packet
            packet_data.add s[i+1..<min(i+5, s.len)]
            i += 5
            result = newIntLitNode(packet_data.parseBinInt)
        else:
            # operator
            let length_type_id = s[i]
            i += 1
            var args: seq[NimNode]
            if length_type_id == '0':
                # 15 bit bit length
                let bit_length = s[i..<(i+15)].parseBinInt
                i += 15
                let start_of_subpackets = i
                while i - start_of_subpackets < bit_length:
                    # We just hope this always works the way its meant to 
                    args.add parseBITSproc(s, i)
            elif length_type_id == '1':
                # 11 bit subpacket size
                let subpacket_size = s[i..<(i+11)].parseBinInt
                i += 11
                for _ in 1..subpacket_size:
                    args.add parseBITSproc(s, i)

            case packet_type:
                of 0:
                    result = args.pop()
                    while args.len > 0:
                        result = newCall("+", args.pop(), result)
                of 1:
                    result = args.pop()
                    while args.len > 0:
                        result = newCall("*", args.pop(), result)
                of 2:
                    result = args.pop()
                    while args.len > 0:
                        result = newCall("min", args.pop(), result)
                of 3:
                    result = args.pop()
                    while args.len > 0:
                        result = newCall("max", args.pop(), result)
                of 5:
                    result = newNimNode(nnkCast)
                    result.add ident("int")
                    result.add newCall(">", args[0], args[1])
                of 6:
                    result = newNimNode(nnkCast)
                    result.add ident("int")
                    result.add newCall("<", args[0], args[1])
                of 7:
                    result = newNimNode(nnkCast)
                    result.add ident("int")
                    result.add newCall("==", args[0], args[1])
                else:
                    discard

const SHOWME = true
macro parseBITS(input: static[string]): untyped =
    var s: string
    for x in input:
        if x in '0'..'9': 
            s.add (x.int - '0'.int).toBin(4)
        if x in 'A'..'F': 
            s.add (x.int - 'A'.int + 10).toBin(4)
    var myi: int = 0
    result = parseBITSproc(s, myi)
    when SHOWME:
        echo result.treeRepr

echo parseBITS(test2)