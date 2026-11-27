"""Independent exact sparse and padded dense Rule 643 simulations (stdlib only)."""
from pathlib import Path
import json

def bit_rule(c, k):
    return (643 >> (c + 2*k)) & 1

def readable_rule(c, k):
    return int(k == 0 or (c == 1 and k >= 3))

def validate():
    for mask in range(32):
        bits = [(mask >> i) & 1 for i in range(5)]
        assert bit_rule(bits[0], sum(bits[1:])) == readable_rule(bits[0], sum(bits[1:]))
    table = {}
    for line in Path('sources/b283508.txt').read_text().splitlines():
        if line.strip() and not line.startswith('#'):
            n, value = map(int, line.split())
            table[n] = value
    horizon = max(table)
    radius = 2*horizon+1
    size = 2*radius+1
    dense = [bytearray(size) for _ in range(size)]
    dense[radius][radius] = 1
    background, deviations = 0, {(0, 0)}
    offsets = [(1,0),(-1,0),(0,1),(0,-1)]
    stable = {(x,y) for x in range(-1,2) for y in range(-1,2) if (x,y)!=(0,0)}
    for n in range(horizon+1):
        sparse_bits = [background ^ ((x,0) in deviations) for x in range(n+1)]
        dense_bits = list(dense[radius][radius:radius+n+1])
        assert sparse_bits == dense_bits, ('implementations',n)
        value = int(''.join(map(str, sparse_bits)))
        if n in table: assert value == table[n], ('OEIS',n)
        if n>0: assert value == (91*10**n-10)//90, ('formula',n)
        if n>=2: assert background==1 and deviations==stable, ('fixed grid',n)
        if n==horizon: break
        def cell(x,y): return background ^ ((x,y) in deviations)
        candidates = {(x+dx,y+dy) for x,y in deviations for dx,dy in [(0,0)]+offsets}
        next_bg = bit_rule(background, 4*background)
        next_diff = set()
        for x,y in candidates:
            k = sum(cell(x+dx,y+dy) for dx,dy in offsets)
            if bit_rule(cell(x,y),k) != next_bg: next_diff.add((x,y))
        background,deviations = next_bg,next_diff
        # Boundary cells are forced OFF. Padding keeps their influence outside observations.
        nxt = [bytearray(size) for _ in range(size)]
        for y in range(1,size-1):
            prev,row,after = dense[y-1],dense[y],dense[y+1]
            out=nxt[y]
            for x in range(1,size-1):
                out[x]=readable_rule(row[x],prev[x]+after[x]+row[x-1]+row[x+1])
        dense=nxt
    result = dict(neighborhoods=32, table_terms=len(table), max_step=horizon,
                  dense_radius=radius, independent_simulators_agree=True,
                  fixed_configuration_from_step=2)
    print(json.dumps(result,indent=2))
    return result

if __name__ == '__main__': validate()
