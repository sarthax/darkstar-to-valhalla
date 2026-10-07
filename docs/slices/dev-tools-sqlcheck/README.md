# sqlcheck.py + DBtool.py pre-import check
`tools/sqlcheck.py` statically checks sql/*.sql dumps before import (column count vs CREATE TABLE, row terminators,
quote/paren balance, duplicate primary keys). `tools/DBtool.py` runs it before dropping any table and aborts on failure
(skips with a warning if sqlcheck.py is missing). Python stdlib only; no server restart needed.
Test: `py -3 tools/DBtool.py` on an intact tree passes; corrupt one INSERT row and confirm it aborts before DROP.
