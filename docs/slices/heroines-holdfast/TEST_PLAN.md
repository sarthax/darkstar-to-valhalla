# Heroines' Holdfast (instance 80) - Live Test Plan

STATUS: SQL imported to `dspdb_fresh`; nothing tested in game. Read `BLOCKERS_FOR_REVIEW.md` first (decisions to review).

| # | Step | Expected | Result |
|---|------|----------|--------|
| 1 | Verify SQL applied in order (instance_list ... instance_entities) and map-server restarted | No errors | |
| 2 | Enter via `!wa` and via Naja_Salaheem path | Instance 80 loads | |
| 3 | Battles 1-6 in sequence | Each spawns correct mobs, advances | |
| 4 | Sixth battle Unsung Heroine gate | Inferred, not capture-confirmed; record real behavior | |
| 5 | csid 300-305 cutscenes | Play without freezing; 8-value padding | |
| 6 | NPC text/message ids | Topaz-derived (+15 vs dialog.yml in Nyzul); check text is correct, else fix | |
| 7 | Dedicated skill lists 1154-1157 | Mobs use expected skills; shared lists untouched | |
| 8 | Overridden mobskills (auroral_uppercut, nullifying_dropkick in Nyzul zone 77 only, shield_bash) | CoP/Nyzul behavior preserved | |
| 9 | Cheerleader emotes | No-op on DSP (expected) | |
| 10 | Time limit | Uses HH_BonusMs fallback | |
| 11 | Rune timer (csid 95 path) | Reposition works | |
| 12 | activateRune floor message | Known dead code carried over | |
| 13 | Rewards/exit | Works | |
| 14 | Instance 52 interplay (Naja_Salaheem row, shared lists) | No conflict | |
| 15 | Map log | No missing-pool/skill errors | |
