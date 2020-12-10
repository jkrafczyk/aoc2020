#!/usr/bin/env python3
lines = open("input").read()

joltages = list(sorted(int(l.strip()) for l in lines.split() if l.strip()))
max_j = max(joltages)

def permutations(start, remaining, memo = {}):
    if start == max_j:
        return 1
    result = 0

    candidates = []
    for i in [2,1,0]:
        if i < len(remaining) and remaining[i] <= start + 3:
            candidates.append((remaining[i], remaining[i+1:]))
    
    for next_start, next_remaining in candidates:
        if next_start not in memo:
            memo[next_start] = permutations(next_start, next_remaining, memo)
        result += memo[next_start]
    return result    



print(permutations(0, joltages))
