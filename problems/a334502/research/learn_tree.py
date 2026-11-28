import numpy as np
from sklearn.tree import DecisionTreeClassifier, export_text
import json,pickle
from pathlib import Path
P=Path(__file__).resolve().parent
names=['clip_n','clip_t','clip_x','clip_n-x','clip_2t-n','clip_x-t','clip_x+t-n','clip_4x-2t-n','clip_4x-2t+3n','clip_2t-3n','clip_2x-n','n%8','(t+x-n)%3','(4t-x)%12','(4t-x+n)%12','(4t-x+2n)%12','(4t-x+3n)%12','t%4','x%4','(t+x-n//2)%3','(t+x+n//2)%3','(4t-x-n//2)%12']
def features(n,t,x):
 n,t,x=np.broadcast_arrays(n,t,x)
 raw=[n,t,x,n-x,2*t-n,x-t,x+t-n,4*x-2*t-n,4*x-2*t+3*n,2*t-3*n,2*x-n]
 return np.stack([np.clip(z,-32,32) for z in raw]+[n%8,(t+x-n)%3,(4*t-x)%12,(4*t-x+n)%12,(4*t-x+2*n)%12,(4*t-x+3*n)%12,t%4,x%4,(t+x-n//2)%3,(t+x+n//2)%3,(4*t-x-n//2)%12],axis=-1).reshape(-1,len(names))
def step(n,w):
 m=(1<<n)-1;l=((w<<1)|(w>>(n-1)))&m;r=((w>>1)|(w<<(n-1)))&m
 return ((~l&(w|r))|(l&~w))&m
def dataset(ns):
 xx=[];yy=[]
 for n in ns:
  w=1; rows=[]
  for t in range(2*n+40):
   rows.append([(w>>x)&1 for x in range(n)])
   w=step(n,w)
  xx.append(features(n,np.arange(2*n+40)[:,None],np.arange(n)[None,:]))
  yy.extend(rows)
 # yy rows have varying lengths
 return np.concatenate(xx),np.concatenate([np.array(y,dtype=np.uint8) for y in yy])
if __name__=='__main__':
 X,y=dataset(range(14,121))
 clf=DecisionTreeClassifier(random_state=0)
 clf.fit(X,y)
 print('samples',len(y),'nodes',clf.tree_.node_count,'depth',clf.tree_.max_depth,'train',clf.score(X,y),flush=True)
 pickle.dump(clf,open(P/'tree.pkl','wb'))
 (P/'tree.txt').write_text(export_text(clf,feature_names=names,max_depth=100))
 X,y=dataset(range(121,151))
 print('validation',clf.score(X,y),'errors',np.count_nonzero(clf.predict(X)!=y),flush=True)
