import re,csv,collections,json
t=open('bluegartr/voidwatch_thread.md',encoding='utf-8').read()
posts=[]
for blk in t.split('\n\n---\n\n'):
    m=re.match(r'(?:# .*\n\n)?## (#\d+) \| (.*?) \| (.*?) \| page (\d+) \| post (\d+)\n\n(.*)',blk,re.S)
    if m: posts.append(dict(n=m[1],u=m[2],d=m[3],p=int(m[4]),id=m[5],t=m[6]))
print(len(posts))
nms=[r['wiki'] for r in csv.DictReader(open('vwnm_inventory.csv',encoding='utf-8'))]
cnt={n:[i for i,p in enumerate(posts) if re.search(r'\b'+re.escape(n)+r'\b',p['t'],re.I)] for n in nms}
for n,v in sorted(cnt.items(),key=lambda x:-len(x[1])): print(n,len(v))
json.dump(posts,open('bluegartr/posts.json','w'))
