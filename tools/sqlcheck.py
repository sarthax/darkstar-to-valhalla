#!/usr/bin/env python3
"""Static pre-import check for sql/*.sql dump files (standard library only).

A plain `mysql < file.sql` import stops at the first bad statement, and every file starts with
DROP TABLE / CREATE TABLE -- so one corrupt row leaves the table truncated. This checks every
single-row `INSERT INTO t VALUES (...)` BEFORE anything is imported:

  * value count matches the CREATE TABLE column count in the same file
  * the row is closed by `);` (missing/garbled terminators, junk glued after the paren)
  * quotes and parentheses balance
  * no duplicate PRIMARY KEY values within the file

Usage:  sqlcheck.py [file.sql ...]      (default: every sql/*.sql next to this tool)
Exit code 1 if any problem is found.
"""
import os
import re
import sys

SQL_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'sql')
BS = chr(92)
INSERT_RX = re.compile(r"INSERT INTO `(\w+)` ?VALUES ?\(")
TABLE_RX = re.compile(r"CREATE TABLE `(\w+)` \((.*?)\)\s*ENGINE", re.S)
PK_RX = re.compile(r"PRIMARY KEY \(([^)]*)\)")


def _split(body):
    """Split a VALUES body into top-level fields (quote aware). Returns the list of raw strings."""
    out, cur, q, i = [], [], False, 0
    while i < len(body):
        c = body[i]
        if q:
            cur.append(c)
            if c == BS:
                i += 1
                cur.append(body[i:i + 1])
            elif c == "'":
                if body[i + 1:i + 2] == "'":
                    i += 1
                    cur.append("'")
                else:
                    q = False
        elif c == "'":
            q = True
            cur.append(c)
        elif c == ',':
            out.append(''.join(cur))
            cur = []
        else:
            cur.append(c)
        i += 1
    out.append(''.join(cur))
    return out


def _tables(text):
    """{table: (column_names, primary_key_columns)} from the CREATE TABLE statements in the file."""
    info = {}
    for m in TABLE_RX.finditer(text):
        cols, pk = [], []
        for line in m.group(2).split('\n'):
            line = line.strip()
            if line.startswith('`'):
                cols.append(line.split('`')[1])
            pm = PK_RX.search(line)
            if pm:
                pk = [p.strip().strip('`') for p in pm.group(1).split(',')]
        info[m.group(1)] = (cols, pk)
    return info


def _statements(line):
    """Yield (table, body, tail_ok_or_message) for each INSERT on a line."""
    pos = 0
    for m in INSERT_RX.finditer(line):
        if m.start() < pos:
            continue
        start, q, i, depth = m.end(), False, m.end(), 1
        while i < len(line):
            c = line[i]
            if q:
                if c == BS:
                    i += 1
                elif c == "'":
                    if line[i + 1:i + 2] == "'":
                        i += 1
                    else:
                        q = False
            elif c == "'":
                q = True
            elif c == '(':
                depth += 1
            elif c == ')':
                depth -= 1
                if depth == 0:
                    break
            i += 1
        if depth != 0:
            yield m.group(1), None, 'row is not closed (unbalanced quote/parenthesis)'
            return
        tail = line[i + 1:]
        nxt = tail.lstrip()[:1]
        msg = ''
        if nxt != ';':
            msg = 'missing ";" after ")"' if nxt == '' else 'junk after ")": %r' % line[i:i + 14]
        else:
            rest = tail.lstrip()[1:].lstrip()
            if rest and not rest.startswith(('INSERT INTO', '--', '/*')):
                msg = 'junk after ");": %r' % rest[:14]
        pos = i
        yield m.group(1), line[start:i], msg


def check_file(path):
    """Return a list of human-readable problems for one .sql file."""
    text = open(path, 'rb').read().decode('utf-8', 'replace')
    info = _tables(text)
    problems, seen = [], {}
    for ln, line in enumerate(text.split('\n'), 1):
        line = line.rstrip('\r')
        if not line.startswith('INSERT INTO'):
            continue
        got = False
        for table, body, msg in _statements(line):
            got = True
            if msg:
                problems.append((ln, msg))
            if body is None:
                continue
            fields = _split(body)
            cols, pk = info.get(table, ([], []))
            if cols and len(fields) != len(cols):
                problems.append((ln, '%s: %d values but table has %d columns' % (table, len(fields), len(cols))))
                continue
            if pk and all(k in cols for k in pk):
                key = (table,) + tuple(fields[cols.index(k)].strip() for k in pk)
                if key in seen:
                    problems.append((ln, '%s: duplicate PRIMARY KEY %s (first on line %d)' % (table, key[1:], seen[key])))
                else:
                    seen[key] = ln
        if not got:
            problems.append((ln, 'INSERT line not recognised (expected "INSERT INTO `t` VALUES (...);")'))
    return problems


def check_files(paths, limit=5, out=print):
    """Check several files; print a summary. Returns True when everything is clean."""
    clean = True
    for p in paths:
        probs = check_file(p)
        if probs:
            clean = False
            out('  %s: %d problem(s)' % (os.path.basename(p), len(probs)))
            for ln, msg in probs[:limit]:
                out('     line %d: %s' % (ln, msg))
            if len(probs) > limit:
                out('     ... %d more' % (len(probs) - limit))
    return clean


if __name__ == '__main__':
    targets = sys.argv[1:] or [os.path.join(SQL_DIR, f) for f in sorted(os.listdir(SQL_DIR)) if f.lower().endswith('.sql')]
    ok = check_files(targets)
    print('sqlcheck: %s (%d file(s))' % ('OK' if ok else 'PROBLEMS FOUND', len(targets)))
    sys.exit(0 if ok else 1)
