# DSP vs LSB mob skill audit for Voidwatch NMs (Phase 1 step 6) — 2026-10-06
Data: `skill_diff.csv` (per NM). Method: parse `mob_pools.skill_list_id` (col 24 both), `mob_skill_lists`, `mob_skills` in dsp-master vs landsandboat-reference.

## CORRECTION
Earlier note "skill_list id numbering differs (Kaggen 340 vs 453)" was WRONG: col 4 of mob_pools is `familyid` (DSP) vs `speciesid` (LSB), unrelated to skills.
**skill_list_id is identical for all 59 VW pools present in both.** mob_skill ids are shared numbering too.

## Results [V]
- 306 distinct skill ids appear in the lists used by the 71+2 VW NMs. All exist as rows in DSP `mob_skills` (none absent), but:
  - **23 are commented out** in DSP `mob_skills.sql` (engine/Lua never implemented): e.g. Kaleidoscopic Fury (2758; Aello, Celaeno, Ocythoe), Meteor (Kholomodumo), Holy Moly's 5 plant skills,
    Ushumgal (calcifying_mist, oppressive_gaze), Brekekekex (frog_song, providence), Tangaroa (4), Sallow Seymour spirit_vacuum, Lord Asag nocturnal_servitude, Asb/Rukh/Sarbaz banneret_charge+enthrall, 2 unnamed (2501, 2555: Hahava/Kalasutrax/Uptala).
  - **~104 have a live SQL row but no same-named Lua file** in `scripts/globals/mobskills/` (approximate: name-match only, Lua filenames may differ) — e.g. Asb/Rukh/Sarbaz dark skills, Agathos, Lord Asag, Cherufe/Stachysaurus, Rw Nw Prt M Hrw (amatsu_*). A skill without Lua = fails/does nothing.
- 6 NMs have lists that differ slightly (Hahava, Kalasutrax, Uptala 16 vs 18; Ildebrann, Yatagarasu, Tangaroa) — DSP list is older era; do not blindly copy LSB.
- 12 NMs have no DSP pool, so no list needed until pools are inserted (skill_list_ids 471,451,316,207,27,217,212,340,803,72 would then also be checked: lists absent in DSP for those ids).
## Implication
Skill work is real but bounded: ~23 unimplemented + ~100 Lua gaps (many shared with other content). Verify Lua-gap count by id->script mapping (not name) before estimating. Ship NMs with only implemented skills first (MVP).
