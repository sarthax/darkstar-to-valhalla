import sys,glob,yaml,mysql.connector,difflib,re
CN=mysql.connector.connect(host='127.0.0.1',user='root',password='UF6uthty',database='dspdb_fresh');M=CN.cursor()
S='C:/Users/Kevin/AppData/Local/Temp/claude/D--Claude/bf255238-11ec-43d4-8e92-43aa5ef1393a/scratchpad/pulls'
norm=lambda n:re.sub(r'[^a-z0-9]','',(n or '').lower())
def plan(z):
    M.execute("select npcid,name from npc_list where (npcid>>12)&0xFFF=%s order by npcid",(z,)); d=M.fetchall()
    y=yaml.safe_load(open(glob.glob(f'{S}/z{z}/*/entities.yml')[0],encoding='utf-8')); L=y if isinstance(y,list) else next(v for v in y.values() if isinstance(v,list))
    cl=sorted((e['id'],e.get('name') or '') for e in L)
    base=cl[0][0]&~0xFFF
    first=min(i for i,n in d if re.match(r'(planar|riftworn|cavernous)',n.replace('_',' ').lower()))
    dd=[(i,n) for i,n in d if i>=first-60]; cc=[(i,n) for i,n in cl if i>=first-60-20]
    sm=difflib.SequenceMatcher(None,[norm(n) for i,n in dd],[norm(n) for i,n in cc],autojunk=False)
    mv=[]
    for a,b,sz in sm.get_matching_blocks():
        for k in range(sz):
            (di,dn),(ci,cn)=dd[a+k],cc[b+k]
            if di!=ci and norm(dn) not in ('blank',''): mv.append((di,ci,dn,cn))
    return dd,cc,mv
if __name__=='__main__':
    for z in map(int,sys.argv[1:]):
        dd,cc,mv=plan(z); print(z,len(mv))
        for di,ci,dn,cn in mv: print(' ',di&0xFFF,'->',ci&0xFFF,dn)
