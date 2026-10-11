# Home point audit: DSP (master-dsp) vs LSB (baf0b36e, 2026-08-17)

Method: scripts in this folder parse both trees' `scripts/globals/homepoint.lua`, `HomePoint#N.lua` NPC scripts and `sql/npc_list.sql`; cross-checked against the BG Wiki home point list (counts match LSB's 121 points per zone).

## Fixed in this branch
1. **Uleguerand Range: all 5 home points missing.** `npc_list` held only commented `NOT_CAPTURED` zero-position placeholders (ids 16798151-55). Now real rows (positions/rotation from LSB). Ids kept in this tree's layout (LSB id - 1). Import: `sql/slices/homepoint-audit-fixes/uleguerand_homepoints.sql`.
2. **Bastok Markets #1 warp destination** was (-293,-10,-102), 74 yalms from the crystal at (-344,-10,-155). Now (-342,-10,-154) (LSB value).
3. **Port Bastok #1 warp destination** was (58.85,7.5,-27.79), 76 yalms from the crystal at (126,8.5,8). Now (124,8,7) (LSB value).

## Found, not fixed (need verification)
- `HOMEPOINT_SET` missing from TextIDs in Leafallia, Toraimarai_Canal, Southern_San_dOria_[S], Bastok_Markets_[S]; the NPC script calls `messageSpecial(HOMEPOINT_SET)` with nil. Real ids need a same-session dialog.yml / dat-extractor pull.
- Ru'Aun Gardens #2/#3 (idx 60/61) are swapped relative to LSB in both table and npc_list. DSP is internally consistent; swapping changes which saved-mask bit maps to which crystal, so left alone.
- Mount Zhayolm #1: warp destination (-540.8,70.8) is 16 yalms from the crystal (-533,56.5) in both DSP and LSB; the DSP comment says "No valid location".
- Orientation (npc_list rot) differs from LSB in ~14 rows (e.g. Southern San d'Oria #1 206 vs 0, Port San d'Oria #3 124 vs 192, Norg #2 251 vs 128, Tavnazian #2/#3 0 vs 145/224). DSP values look capture-derived; not changed.
- Small position differences vs LSB: Den of Rancor #2, Fei'Yin #2, Newton Movalpolos #1, Norg #2, Metalworks #1.
- Al Zahbi #1 (idx 67) has no crystal in retail (dest 0,0,0); harmless as nothing references it.
- `HOMEPOINT_TELEPORT = 0` and `HOMEPOINT_HEAL = 0` in `scripts/globals/settings.lua`: teleport menu is off unless the server sets it.
- Verified equal to LSB: all 122 table fees, free-teleport groups, mask param/bit layout, all NPC-script indices and event ids.
