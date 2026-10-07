# Item script repair package

Fixes for weapons whose additional effect (mod 431) never procs on the DSP/Valhalla server because the
per-item Lua script is missing, misnamed or a stub. See REPORT.md for the full table.

| Folder / file | Count | What it is |
|---|---|---|
| `ready/` (lua) | 4 | Drop-in scripts. Every value is sourced; assumptions are written in each file's header and in manifest.json. |
| `ready/RENAMES.txt` | 1 | Working script saved under the wrong filename; rename only. |
| `needs-values/` | 6 | Effect and element confirmed by BG Wiki, chance/amount blank because neither LandSandBoat nor the wiki states them. Not loadable until filled. |
| `manifest.json` | | `out_of_scope` lists items above level 90 (server cap), not worked on. |
| | | `no_data` lists 0 item(s) with no source at all. |
| `stubs.md` | | Verdict on the 29 stub files: 27 are intentionally empty (fireworks, fans), 3 reviewed individually. |

## Apply
```
python apply.py <server_root> --dry-run
python apply.py <server_root>
```
Then restart the map server. Existing scripts with behavior are never overwritten; stubs are backed up.

## Caveats
- LandSandBoat marks several of these as plain DAMAGE with no numbers (a placeholder), so it is not evidence of the real effect; the wiki is.
- Generated values are LSB's or the wiki's and are not retail-verified on this server. Test in game.
- Twilight Knife's DSP data has Quad Attack 10 where the wiki says +3% (separate data question).
