# Instance 52 (Uncharted Area Survey) - blockers for review (2026-10-02, overnight run)

Delta package: apply nyzul_isle_investigation first. Built from IDs.lua, old id - 129 (option 1).

## Done
- sql-dsp: 30 pools (6998-7027), 30 groups (18166-18195), 52 spawns, 386 instance_entities, instance_list row, skill list 285, npc Naja_Salaheem 17093464. No collisions vs dspdb_fresh.
- lua-dsp: 28 files, all pass a lupa syntax check. Copied into D:\Claude\dsp-master\scripts (uncommitted).
- Fixed a real syntax error in shared Rune_of_Transfer.lua (two stray `else` after the startEvent(95) timer loops); now uses the dsp-master timer-reposition form. Copied to dsp-master too.
- SQL NOT applied to any DB. Apply sql-dsp/*.sql to dspdb (or dspdb_fresh) yourself.

## Blockers / needs your decision
1. Live tpzdb does not match IDs.lua (relocation never applied in Topaz DB); archive-topaz-sql is stale Topaz extraction, do not use.
2. Boss rows: old base rows 502/507/512/517/534 not emitted; self ids 127-131 use groups 339/342/345/349/347 (-> 18166+ mapped). Confirm intended.
3. Leader spawn positions are (1,1,1) placeholders, set at runtime via setSpawn.
4. Skills 1800 (miasma), 1801 (vorpal_wheel) missing in DSP mob_skills: skipped.
5. Skill lists 1149/171/316/63/112 differ between Topaz and DSP; DSP versions kept, Topaz extras not carried.
6. Stheno Eagle Eye Shot (75% roll, useMobAbility 1931) reimplemented, not verbatim. Eye_Piercer/Qiqirn EES and other NM kit gaps left unbuilt per Topaz headers.
7. Naja_Salaheem script not ported (TOAU script); only npc row added.
8. Unverified: csid padding and text ids on the 52 paths, Berangere text ids. No in-game test possible; only syntax checked.
9. Open from before: 4 Lebros instances + verify_instances.lua not yet in lua-dsp; dsp-master vs package reconcile (3 junk spawn rows, Reserve_Draugar z); nothing pushed to valhalla.

10. 2026-10-03: Haraal skills moved from ids 3900-3904 to 1797-1801 (client chat name comes from the skill id). 1797-1799 keep pw_* names/Lua (gated to model 1863 = Haraal's); anims changed to 1320-1322; 1800/1801 added. Apply sql-dsp/haraal_ja_skills_2026-10-03.sql after the other sql-dsp files.
