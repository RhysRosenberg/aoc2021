import std/strscans
import std/strutils
import std/sequtils

const part = 2
let input = readFile("test.txt")

var parsed_input: string

for x in input:
    if x in '0'..'9': 
        parsed_input.add (x.int - '0'.int).toBin(4)
    if x in 'A'..'F': 
        parsed_input.add (x.int - 'A'.int + 10).toBin(4)

when part == 1:
    proc do_stuff(s: string, i: var int): int = 
        let packet_version = s[i..<i+3].parseBinInt()
        i+=3
        result += packet_version
        let packet_type = s[i..<i+3].parseBinInt()
        i+=3
        echo "VERSION:", packet_version, " TYPE ", packet_type, " LEN ", s.len
        case packet_type:
            of 4:
                # literal
                echo "LITERAL"
                var packet_data: string
                while s[i] != '0':
                    # While we haven't hit the end packet
                    # Consume packet data
                    packet_data.add s[i+1..<i+5]
                    i += 5
                # Now handle last packet
                packet_data.add s[i+1..<min(i+5, s.len)]
                i += 5
                echo packet_data
            else:
                # operator
                echo "OPERATOR"
                let length_type_id = s[i]
                i += 1
                if length_type_id == '0':
                    # 15 bit bit length
                    let bit_length = s[i..<(i+15)].parseBinInt
                    i += 15
                    let start_of_subpackets = i
                    while i - start_of_subpackets < bit_length:
                        # We just hope this always works the way its meant to 
                        result += do_stuff(s, i)
                elif length_type_id == '1':
                    # 11 bit subpacket size
                    let subpacket_size = s[i..<(i+11)].parseBinInt
                    i += 11
                    for _ in 1..subpacket_size:
                        echo "rest is ", s[i..^1]
                        result += do_stuff(s, i) 
else:
    proc do_stuff(s: string, i: var int): int = 
        let packet_version = s[i..<i+3].parseBinInt()
        i+=3
        let packet_type = s[i..<i+3].parseBinInt()
        i+=3
        echo "VERSION:", packet_version, " TYPE ", packet_type, " LEN ", s.len
        case packet_type:
            of 4:
                # literal
                echo "LITERAL"
                var packet_data: string
                while s[i] != '0':
                    # While we haven't hit the end packet
                    # Consume packet data
                    packet_data.add s[i+1..<i+5]
                    i += 5
                # Now handle last packet
                packet_data.add s[i+1..<min(i+5, s.len)]
                i += 5
                result = packet_data.parseBinInt
            else:
                # operator
                echo "OPERATOR"
                let length_type_id = s[i]
                i += 1
                var args: seq[int]
                if length_type_id == '0':
                    # 15 bit bit length
                    let bit_length = s[i..<(i+15)].parseBinInt
                    i += 15
                    let start_of_subpackets = i
                    while i - start_of_subpackets < bit_length:
                        # We just hope this always works the way its meant to 
                        args.add do_stuff(s, i)
                elif length_type_id == '1':
                    # 11 bit subpacket size
                    let subpacket_size = s[i..<(i+11)].parseBinInt
                    i += 11
                    for _ in 1..subpacket_size:
                        echo "rest is ", s[i..^1]
                        args.add do_stuff(s, i) 
                case packet_type:
                    of 0:
                        # Sum
                        result = args.foldl(a + b)
                    of 1:
                        result = args.foldl(a * b)
                    of 2:
                        result = args.min()
                    of 3:
                        result = args.max()
                    of 5:
                        result = if args[0] > args[1]:
                            1
                        else:
                            0
                    of 6:
                        result = if args[0] < args[1]:
                            1
                        else:
                            0
                    of 7:
                        result = if args[0] == args[1]:
                            1
                        else:
                            0
                    else:
                        discard

var i = 0
echo do_stuff(parsed_input, i)