"""Builds docs/voidwatch/NM-DETAILS.html (the pinnable artifact source) from NM-DETAILS.md + NM-DETAILS-NOTES.md.
Run from repo root: py -3 docs/voidwatch/gen_nm_details_html.py   (run gen_nm_details.py first if SQL/scripts changed)"""
import re, json, html
def tbl(lines):
    rows = []
    for l in lines:
        if l.startswith('|') and not re.match(r'^\|[-| ]+\|$', l):
            rows.append([x.strip() for x in l.strip().strip('|').split('|')])
    return rows
det = open('docs/voidwatch/NM-DETAILS.md', encoding='utf-8').read().split('\n')
summ = [r for r in tbl([l for l in det if l.startswith('| ')][:60]) if len(r) == 9 and r[0] != 'NM']
notes = open('docs/voidwatch/NM-DETAILS-NOTES.md', encoding='utf-8').read().split('\n## ')[1:]
nm = {}
for sec in notes:
    head, *rest = sec.split('\n'); name = re.match(r'(.+?) \(', head).group(1)
    prose = [l for l in rest if l and not l.startswith('|')]
    rows = [r for r in tbl(rest) if len(r) == 5 and r[0] != 'field']
    nm[name] = {'prose': prose, 'rows': rows}
def cls(v):
    v = v.replace('*', '').lower()
    if v.startswith(('contradicted', 'mismatch', 'missing')): return 'bad'
    if v.startswith('yes'): return 'ok'
    if v.startswith(('partial', 'user-stated')): return 'part'
    if v.startswith('n/a'): return 'na'
    return 'unk'
data = []
for r in summ:
    n = r[0]; led = nm.get(n, {'prose': [], 'rows': []})
    rows = [dict(f=x[0], v=x[1], s=x[2], ok=x[3].replace('*', ''), n=x[4], c=cls(x[3])) for x in led['rows']]
    data.append(dict(name=n.replace('_', ' '), zone=r[1].replace('_', ' '), lv=r[2], mt=r[3], job=r[4], hp=r[5], sk=r[6], sp=r[7], dr=r[8], prose=' '.join(led['prose']), rows=rows))
tpl = open('docs/voidwatch/nm_details_template.html', encoding='utf-8').read()
open('docs/voidwatch/NM-DETAILS.html', 'w', encoding='utf-8').write(tpl.replace('__DATA__', json.dumps(data, ensure_ascii=False).replace('</', '<\/')))
print(len(data), 'NMs')
