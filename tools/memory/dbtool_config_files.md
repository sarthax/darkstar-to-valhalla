---
name: dbtool-missing-config-files
description: Documented expected missing config files for DBtool.py
metadata:
  type: reference
---

DBtool.py expects these config files that don't exist in git repo (created on first run):

- ../conf/version.conf - Database version info
- ../conf/default/version.conf - Client version info

These are created automatically when the tool runs with valid database credentials. See [[dbtool-missing-init-py]] for the import fix.

Related: [[dbtool-missing-init-py]]
