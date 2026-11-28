from learn_tree import step
from itertools import groupby
import sys
for n in ([int(sys.argv[1])] if len(sys.argv)>1 else range(240,248)):
 w=1;out=[]
 selected={0,1,2,3,4,5,6,12,24,n//2-12,n//2-6,n//2-3,n//2-2,n//2-1,n//2,n//2+1,n//2+2,n//2+3,n//2+6,n//2+12,n,n+12,3*n//2-12,3*n//2,3*n//2+12,2*n}
 for t in range(2*n+1):
  if t in selected:
   blocks=[format((w>>x)&4095,'012b')[::-1] for x in range(0,n,12)]
   runs=[f'{sum(1 for _ in g)}*{v}' for v,g in groupby(blocks)]
   print(n,t,' '.join(runs))
  w=step(n,w)
