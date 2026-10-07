# mob_pools / mob_groups id plan (Phase 1 step 6a) — 2026-10-06

## Pools [V] (dsp-master vs landsandboat-reference, by poolid)
DSP and LSB share the same poolid numbering for VW NMs. Of 71 rows with an LSB pool:
- **53** same id + same name in DSP -> reuse as is (schema 22 vs 28 cols still needs conversion; skill_list_id column DIFFERS, e.g. Kaggen 340 vs 453 — remap by name, don't copy).
- **6** same id, spelling differs only (DSP name `Bishani/Bismark/Brekekex/Lorbulcrub/Murk_veinedBan/Roly_Poly` vs LSB `Bhishani/Bismarck/Brekekekex/Lorbulcrud/Murk-veined_Baneberry/Roly-Poly`)
  -> same pool, keep DSP row; name only matters if scripts look up by name.
- **12** absent in DSP, LSB ids free in DSP (max DSP poolid 7057, these not used): Celaeno 6890, Cetus 6821, Fjalar 6814, Holy Moly 6847, Isarukitsck 6811,
  Malleator Maurok 6900, Neith 6726, Sabotender Campeador 6851, Tsui-Goab 6739, Ushumgal 6820, Voidwrought 6724, Yalungur 6755 -> insert with LSB ids (**re-check against live DB first**).
- Gasha/Pil are not name-match gaps: LSB `Gasha-1stform` 5179 + later forms, `Pil_VNM` 4695 / `Pil_provenance` 5315 — all present in DSP (as `Pil-VNM`, `Pil-Provenance`). Nympha_Eunomia 4699 (LSB) — check DSP.
- Add Kaggen 4694, Modron 5159 (+ Modron's Druid 5160), both present in DSP.
- (Earlier "49/71 pools" figure came from name matching; by id it is 59 present + 12 missing.)

## Groups [V] — must be RENUMBERED
- DSP `mob_groups` PK = bare global `groupid` (LSB/Topaz are per-zone composite), so LSB groupids collide with unrelated DSP rows. User confirmed 2026-10-06: assign new groups.
- Precedent (Nyzul, `Topaz-Assault-Backport/mission-packages/nyzul_isle_investigation/ID_COLLISION_REPORT.md`): renumber into a block above DSP's max, preserve relative order, update `mob_spawn_points.groupid`, re-check live DB.
- dsp-master max groupid is now **18225** (Nyzul block lives at ~17000-18225). Candidate VW block: start at **18300** (leave headroom for Nyzul/Salvage growth), ~75 NMs x 1-3 groups ≈ <=250 ids -> 18300-18549. **Proposal only — confirm against live DB before applying.**
- Also check: `mob_spawn_points.mobid` (zone-encoded, bits 12-23 = zoneid; targid <0x400) and `mob_droplist.dropId` (Nyzul precedent renumbered these too) for collisions.

> **SUPERSEDED 2026-10-06 for most NMs — see research/DSP-LIVE-STATE-CORRECTION.md (DSP already has groups 13xxx and partial spawns).**
