#!/usr/bin/env python3
from pprint import pprint

bag_contents = {}

for line in open("input"):
    container, all_contents = line.strip().rstrip('.').split(" bags contain ")
    all_contents = [
        i.split('bag')[0].strip().split(' ', 1) for i in all_contents.split(',')
    ]
    all_contents = {
        i[1]: int(i[0]) for i in all_contents if i != ['no', 'other']
    }
    bag_contents[container] = all_contents

def count_bags(start, state=None, depth = 0):
    children = bag_contents.get(start, {})
    for child in children:
        count_bags(child, state, depth+1)
    
    if not children:
        state[start] = 1
        msg = "leaf"
    else:
        total_cost = 0
        msg = []
        for child in children:
            offset = children[child] * state[child]
            total_cost += offset
            msg += [str(offset) + " (" + child + ")"]
        state[start] = 1 + total_cost
        msg = " ".join(msg)
    print(depth * "  ", start, state[start], " ["+msg+"]")
    return state[start]-1

print(count_bags('shiny gold', {}))
