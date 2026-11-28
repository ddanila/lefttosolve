from learn_tree import step
import numpy as np, json, time
from pathlib import Path
P=Path(__file__).parent
# Leaves are periodic textures, rather than individual bits.
names=['t','x','n-x','2t-n','x-t','x+t-n','4x-2t-n','4x-2t+3n','2t-3n','2x-n','n%24','t%3','t%4','x%4']
def feats(n,t,x):
 n,t,x=np.broadcast_arrays(n,t,x)
 return np.stack([np.clip(z,-32,32) for z in [t,x,n-x,2*t-n,x-t,x+t-n,4*x-2*t-n,4*x-2*t+3*n,2*t-3*n,2*x-n]]+[n%24,t%3,t%4,x%4],axis=-1).reshape(-1,len(names)).astype(np.int8)
def pats(n,t,x):
 n,t,x=np.broadcast_arrays(n,t,x);A=np.array([int(z) for z in '100011010111'],dtype=np.uint8)
 return np.stack([np.zeros_like(x),np.ones_like(x),A[(4*t-x)%12]]+[(t+x-n+j)%3!=2 for j in range(3)]+[(t+x-n//2+j)%3!=2 for j in range(3)]+[A[(4*t-x-n//2)%12]],axis=-1).reshape(-1,10).astype(np.uint8)

def dataset(ns):
 xx=[];pp=[];yy=[]
 for n in ns:
  ts=np.arange(2*n+40)[:,None];xs=np.arange(n)[None,:]
  xx.append(feats(n,ts,xs));pp.append(pats(n,ts,xs))
  w=1
  for t in range(2*n+40):
   yy.extend((w>>x)&1 for x in range(n));w=step(n,w)
 return np.concatenate(xx),np.concatenate(pp),np.array(yy,dtype=np.uint8)
if __name__=='__main__':
 start=time.time();F,PATS,Y=dataset(range(14,121));M=(PATS==Y[:,None]).astype(np.int32)
 nodes=[]
 def fit(indices,depth=0):
  matches=M[indices];count=matches.sum(axis=0);best=int(count.argmax());err=len(indices)-count[best]
  if err==0:return {'pattern':best}
  bestsplit=None;besterr=err;bestbalance=0
  for f in range(F.shape[1]):
   vals=F[indices,f]+32
   hist=np.zeros((65,10),dtype=np.int64);np.add.at(hist,vals,matches)
   sizes=np.bincount(vals,minlength=65);total=np.cumsum(sizes)[:-1];left=np.cumsum(hist,axis=0)[:-1]
   errors=len(indices)-left.max(axis=1)-(count-left).max(axis=1)
   for k in range(64):
    if not 0<total[k]<len(indices):continue
    balance=min(total[k],len(indices)-total[k])
    if errors[k]<besterr or (errors[k]==besterr and balance>bestbalance):
     besterr=errors[k];bestbalance=balance;bestsplit=(f,k-32)
  if bestsplit is None or depth>50:raise RuntimeError((depth,len(indices),err))
  f,k=bestsplit;mask=F[indices,f]<=k
  return {'feature':f,'threshold':k,'left':fit(indices[mask],depth+1),'right':fit(indices[~mask],depth+1)}
 model=fit(np.arange(len(Y)))
 (P/'segment-tree.json').write_text(json.dumps(model,indent=2)+'\n')
 def size(m):return 1 if 'pattern' in m else 1+size(m['left'])+size(m['right'])
 print('nodes',size(model),'seconds',time.time()-start,flush=True)
 F,PATS,Y=dataset(range(121,161))
 def predict(m,idx):
  if 'pattern' in m:return PATS[idx,m['pattern']]
  mask=F[idx,m['feature']]<=m['threshold'];out=np.empty(len(idx),dtype=np.uint8)
  out[mask]=predict(m['left'],idx[mask]);out[~mask]=predict(m['right'],idx[~mask]);return out
 pred=predict(model,np.arange(len(Y)))
 print('validation errors',np.count_nonzero(pred!=Y),flush=True)
