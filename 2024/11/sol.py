import os
import sys
from collections import defaultdict, Counter, deque

sys.setrecursionlimit(10**6)


input_file = os.path.expanduser("~/work/private/adventofcode/2024/11/input.txt")

contents = open(input_file).read().strip()
lines = [line.strip() for line in contents.split("\n")]


mem = defaultdict(int)

def compute_count(sval, blinks):
    if blinks == 0:
        mem[(sval, blinks)] = 1
    if (sval, blinks) in mem:
        return mem[(sval, blinks)]
    # blinking and computing
    if sval == 0:
        mem[(sval, blinks)] = compute_count(1, blinks - 1)
    elif len(str(sval)) % 2 == 0:
        # splitting
        l = len(str(sval))
        s1 = int(str(sval)[:l//2])
        s2 = int(str(sval)[l//2:])
        mem[(sval, blinks)] = compute_count(s1, blinks - 1) + compute_count(s2, blinks - 1)
    else:
        mem[(sval, blinks)] = compute_count(sval * 2024, blinks - 1)
    return mem[(sval, blinks)]

import time
start_time = time.time()
stones = [int(x) for x in lines[0].split(" ")]
num_blinks = 1000
total = 0
for s in stones:
    c = compute_count(s, num_blinks)
    print(s, c)
    total += c
print(total)
end_time = time.time()
print(f"Elapsed time: {end_time - start_time} seconds")