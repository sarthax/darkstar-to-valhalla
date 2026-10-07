import gzip,json,sys,re
p='D:/Claude/FFXI-Tools/ffxi-wiki-dumps-dist/bg-wiki.jsonl.gz'
rows=[]
with gzip.open(p,'rt',encoding='utf-8') as f:
    for l in f:
        try: rows.append(json.loads(l))
        except: pass
print(len(rows), list(rows[0].keys()))
vw=[r for r in rows if any('oidwatch' in c for c in r.get('categories',[]))]
print(len(vw))
import collections
cc=collections.Counter(c for r in vw for c in r['categories'])
print(cc.most_common(30))
json.dump(vw,open(sys.argv[1],'w'))
for r in vw: print(r['title'], '|', ','.join(r['categories'])[:90], '|', len(r.get('wikitext',r.get('text',''))))
