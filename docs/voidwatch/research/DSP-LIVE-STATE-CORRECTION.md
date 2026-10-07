# CORRECTION: DSP already has VW NM pools/groups/spawns (live DB check 2026-10-06)
Earlier findings (FINDINGS-2026-10-06.md §2, POOL-GROUP-ID-PLAN.md, SCOPE) said DSP had 0/71 groups and 0/71 spawn points and that new groups must be created above 18225. **That was wrong**: the inventory tried to match groups by name, but DSP's `mob_groups` has no name column (cols: groupid,poolid,zoneid,respawntime,spawntype,dropid,HP,MP,minLevel,maxLevel,allegiance). Matching by `mob_spawn_points.mobname` against the live DB (`dspdb_fresh`, read-only) gives the real picture (`dsp_live_vw_coverage.csv`):

- Of 73 NMs: **16 full** (spawns >= LSB count), **35 partial** (>=1 spawn row present, missing rows), **20 none** (no pool and/or group/spawn).
- Existing DSP groups use ids ~13xxx (e.g. Sarimanok 13806, Aello 13737, Krabimanjaro 13809, Belphoebe 13782, Hahava 13805), spawntype 128 (scripted), respawntime 0, dropid 0. These are the groups to REUSE; the 18300+ block is not needed for these NMs (still free: max groupid 18225, none in 18300-18999).
- **LSB's 3 spawn rows per NM = the 3 Planar Rift positions** [V]: Aello LSB spawns (375.6,-40,231.0), (-118.7,-40.7,436.1), (91.5,-40.7,-456.0) match DSP Planar_Rift npc 17310111-13 at (377,-40,246), (-117,-40,436), (94,-40.2,-459). So NM i spawns at Rift i. DSP lacks some of these rows (collisions or filtering), so spawn points for missing rifts need adding.

## First-slice NMs (live DB)
| NM | DSP pool | DSP group | DSP spawns (of 3) | Missing LSB mobid | Free in DSP? |
|---|---|---|---|---|---|
| Sarimanok (101) | 5165 | 13806 | 2 (17191335, 17191337) | 17191336 | yes |
| Aello (130) | 4720 | 13737 | 1 (17309993) | 17309985, 17309989 | yes |
| Krabimanjaro (193) | 5168 | 13809 | 3 | — | n/a |
| Belphoebe (104) | 5152 | 13782 | 2 (17203697, 17203698) | 17203696 | yes |
| Hahava (190) | 5164 | 13805 | 3 at 17555901-903 (LSB ids 17555773-775 are taken by Thousand_Eyes/Hati in DSP) | — | keep DSP ids |
Spawn mobids all have targid < 0x400 (e.g. Sarimanok 423-425) [V]; zone bits match.

## Consequences
- Phase 3 data work is much smaller: add missing spawn rows (mapping rift index -> mobid), set dropid, fill pools for the 20 missing NMs (still need pool conversion), plus scripts.
- Open: DSP spawn row columns (mobid,mobname,polutils_name,groupid,pos_x..rotation) differ from LSB (adds mobname/polutils?) — copy per DSP 8-col format; verify dropid source (FFXIDB/LSB); verify the existing DSP pools' stats are non-garbage; confirm `respawntime 0`+spawntype 128 means no autospawn.
- Persistent mem note needed: group-id plan superseded.

## Pools and drops (checked 2026-10-06) [V]
- DSP pools for the 5 slice NMs are real (modelid, jobs, cmbSkill/delay, skill_list_id = familyid-pattern as LSB). Minor diffs vs LSB: Aello name_prefix 32/animationsub 8/spellList 21 in LSB vs 0/0/2 in DSP (spell list ids are DSP-specific; name_prefix/animsub to review when scripting Aello). familyid differs by design.
- LSB groups also have dropid 0 -> NM rewards come from the Pyxis pool, not mob drops. Drop data belongs to the Pyxis reward tables (FFXIDB/wiki), not mob_droplist.
- Draft SQL for the 4 missing slice spawn rows: `draft_vw_missing_spawns.sql` (NOT run). Each row is within 0-15 yalms of its Planar Rift (Sarimanok 17191336 = rift 1 exactly; Aello 985/989 = rifts 0/1; Belphoebe 696 = rift 0), mobid order = rift index. Coordinates copied from LSB; per project rule verify with `!checknav` before applying.
