"""Targeted BG Wiki fetch via MediaWiki API -> wiki_raw/<title>.wiki + manifest. Read-only, polite."""
import json,re,sys,time,urllib.request,urllib.parse,os
API="https://www.bg-wiki.com/api.php"
OUT=os.path.join(os.path.dirname(__file__),"wiki_raw")
def api(**p):
    p["format"]="json"
    req=urllib.request.Request(API+"?"+urllib.parse.urlencode(p),headers={"User-Agent":"ffxi-dsp-research/1.0 (local backport project)"})
    return json.load(urllib.request.urlopen(req,timeout=60))
def page(t):
    d=api(action="query",prop="revisions|categories",rvprop="content|timestamp|ids",rvslots="main",titles=t,redirects=1,cllimit="max")
    for p in d["query"]["pages"].values():
        if "missing" in p: return None
        r=p["revisions"][0]; return {"title":p["title"],"revid":r["revid"],"ts":r["timestamp"],"text":r["slots"]["main"]["*"]}
def members(cat):
    out=[];c=None
    while True:
        d=api(action="query",list="categorymembers",cmtitle=cat,cmlimit="500",**({"cmcontinue":c} if c else {}))
        out+=[m["title"] for m in d["query"]["categorymembers"]]
        c=d.get("continue",{}).get("cmcontinue")
        if not c: return out
if __name__=="__main__":
    titles=sys.argv[1:]
    man=[]
    for t in titles:
        r=page(t); time.sleep(1)
        if not r: print("MISSING",t); continue
        fn=re.sub(r'[^A-Za-z0-9_.-]','_',r["title"])+".wiki"
        open(os.path.join(OUT,fn),"w",encoding="utf-8").write(r["text"])
        man.append({k:r[k] for k in("title","revid","ts")}|{"file":fn,"chars":len(r["text"])}); print("OK",r["title"],len(r["text"]))
    json.dump(man,open(os.path.join(OUT,"_manifest_"+str(int(time.time()))+".json"),"w"),indent=1)
