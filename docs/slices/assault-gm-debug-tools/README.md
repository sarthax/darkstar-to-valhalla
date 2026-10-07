# Backport report -- assault_gm_debug_tools

Target: `D:\Claude\old-dsp-reference` (detected flavor: `old_dsp_reference`)

## Lua conversion
9 file(s) converted, 1 line(s) flagged across 1 file(s).
- `scripts\commands\addassaultpoints.lua` -- 1 flagged line(s)

## Binding audit
43 confirmed, 2 missing.
- MISSING `:printToPlayer(` -- no matching registration for 'printToPlayer' found in cached index (old_dsp_reference_binding_index.json) [used in: addassaultpoints.lua, checknav.lua, fourccanim.lua (+6 more)]
- MISSING `:setUntargetable(` -- no matching registration for 'setUntargetable' found in cached index (old_dsp_reference_binding_index.json) [used in: navdebug.lua, showhelper.lua]

## Lua sanity check
Clean -- no syntax errors, no undeclared global references.

## Overall
**Needs review** -- see the sections above for what to check by hand before treating this package as done.

Commands on this branch: checklocalvar, fourccanim, salvagedrinks, setlocalvar, setstage, wa, warpassault.
Other commands in the package ship with their feature branches (nyzul*, astraria, etc.). GM-only; Lua only.
