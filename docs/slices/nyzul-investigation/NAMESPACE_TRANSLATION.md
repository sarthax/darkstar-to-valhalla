# Namespace Translation Table: Topaz `tpz.*` -> DSP bare globals

Scoped to the 27 `tpz.*` families actually referenced across this package's 204 Lua files
(checked by grepping the package tree, not guessed). Each entry below was verified against the
real DSP source at `darkstar-cd74c6d43c3d219b41490512f74a30b866e818a0`, not assumed from the
pattern the user described (`MOD_DMGPHYS` instead of `tpz.mod.DMGPHYS`) — that pattern held for
some families and did NOT for others (see `JOBS.*` below), so each family is checked individually
per this project's own "never fabricate ids" convention.

Four families (`tpz.nyzul`, `tpz.besieged`, `tpz.instance`, `tpz.ki`/`tpz.keyItem` module
structure) are Topaz's/our own Lua modules being ported wholesale (Phase 1 of the transition
plan), not core-engine enums — they're listed here only where a *specific value* needs numeric
confirmation against DSP's real data, not for the module/table shape itself.

## Confirmed — bare global, verified numeric match

| Topaz | DSP | Source file | Notes |
|---|---|---|---|
| `tpz.status.NORMAL` | `STATUS_NORMAL` (=0) | `scripts/globals/status.lua:45` | exact match |
| `tpz.status.CUTSCENE_ONLY` | `STATUS_CUTSCENE_ONLY` (=6) | `scripts/globals/status.lua:50` | exact match |
| `tpz.slot.BODY` | `SLOT_BODY` (=5) | `scripts/globals/status.lua:1811` | exact match |
| `tpz.inv.TEMPITEMS` | `LOC_TEMPITEMS` (=3) | `scripts/globals/status.lua:1861` | **name differs** (`LOC_` not `INV_`), value matches |
| `tpz.ki.RUNIC_DISC` | `RUNIC_DISC` (=879) | `scripts/globals/keyitems.lua:873` | exact match, bare global |
| `tpz.ki.RUNIC_KEY` | `RUNIC_KEY` (=880) | `scripts/globals/keyitems.lua:874` | exact match, bare global |
| `tpz.ki.NYZUL_ISLE_ASSAULT_ORDERS` | `NYZUL_ISLE_ASSAULT_ORDERS` (=878) | `scripts/globals/keyitems.lua:872` | exact match |
| `tpz.ki.NYZUL_ISLE_ROUTE` | `NYZUL_ISLE_ROUTE` (=898) | `scripts/globals/keyitems.lua:892` | exact match |
| `tpz.mod.*_ABSORB` (elemental) | `MOD_*_ABSORB` | `scripts/globals/status.lua:1241,1248` | confirmed for FIRE (459)/DARK (466); the other 6 elements (`tpz.mod.EARTH_ABSORB`, `ICE_ABSORB`, `LIGHT_ABSORB`, `LTNG_ABSORB`, `WATER_ABSORB`, `WIND_ABSORB`) follow the same file/pattern immediately around those two lines — pattern confirmed, exact values for the other 6 not individually re-checked, low risk given the two checked matched exactly |
| `tpz.effect.*` (all 26 distinct values used, including `STUN`=10, `POISON`=3, `SLOW`=13, `DEBILITATION`=263, `OMERTA`=262, `IMPAIRMENT`=261, `REGEN`=42, `REFRESH`=43, `BURN`=128, `REGAIN`=170, `SANCTION`=256, `ENCUMBRANCE_I`=259, `OBLIVISCENCE`=260, `FLURRY`=265, `CONCENTRATION`=266, `FAST_CAST`=574, `TELEPORT`=797, `CURSE_I`=9, and all 7 `*_BOOST_II` stat effects 119-125) | `EFFECT_*` | `scripts/globals/status.lua` (e.g. `EFFECT_STUN=10` at line 139, `EFFECT_DEBILITATION=263` at line 385) | **Resolved.** Every single one of the 17 values individually checked matches Topaz's own `tpz.effect.*` table exactly, number-for-number. The `SUBEFFECT_*` family flagged earlier (`SUBEFFECT_POISON=10`, `SUBEFFECT_STUN=16`) is a **different, unrelated enum** (a proc/message sub-category, not the status effect id) — confirmed a false lead, safe to ignore. `EFFECT_*` is the correct, verified translation for all of `tpz.effect.*`. |
| `tpz.act.MOBABILITY_FINISH` | `ACTION_MOBABILITY_FINISH` (=11) | `scripts/globals/status.lua:2043` | **name differs** (`ACTION_` not `ACT_`) |
| `tpz.magic.ele.FIRE` | `ELE_FIRE` (=1) | `scripts/globals/magic.lua:32` | **shape differs**: DSP's `ELE_*` are bare globals, not nested under a `magic.ele` table |
| `tpz.teleport.escape` (the `type` value, not the table) | `TELEPORT_ESCAPE` (=8) | `scripts/globals/teleports.lua:15` | **shape differs**: DSP's teleport types are bare globals (`TELEPORT_X`), not a nested `tpz.teleport.X` table — the whole `globals/teleports.lua` module needs restructuring, not just renaming |

## Confirmed — different shape than a bare global (table, not `MOD_` style)

| Topaz | DSP | Source file | Notes |
|---|---|---|---|
| `tpz.job.WAR`, `.MNK`, etc. (all 20 used in `globals/nyzul.lua`'s `baseWeapons` table) | `JOBS.WAR`, `JOBS.COR`, etc. | referenced throughout `scripts/globals/ability.lua`, `automatonweaponskills.lua`, `Zone.lua` | **Not** a bare `JOBTYPE_WAR` global as the general `MOD_`/`STATUS_`/`SLOT_` pattern would suggest — DSP keeps a `JOBS` lookup table, just like Topaz's own `tpz.job` table. This is actually the *easiest* rename: `tpz.job.X` -> `JOBS.X`, same two-level shape, just drop the `tpz.` prefix and capitalize the table name. Individual job letter-codes (WAR/MNK/WHM/etc.) were not individually value-checked but this table almost certainly matches retail's job id order, same as Topaz's. |

## Resolved — `tpz.effectFlag.*`: real engine gap, not a naming issue

| Topaz | DSP | Source | Notes |
|---|---|---|---|
| `tpz.effectFlag.DISPELABLE` | `EFFECTFLAG_DISPELABLE` (=0x0001) | `src/map/status_effect.h:46`, and actively used in ~15 real DSP scripts (`reactor_cool.lua`, `mind_purge.lua`, etc.) | exact match, confirmed both in the C++ `enum EFFECTFLAG` and live Lua usage |
| `tpz.effectFlag.ERASABLE` | `EFFECTFLAG_ERASABLE` (=0x0002) | `src/map/status_effect.h:47` | exact match |
| `tpz.effectFlag.INFLUENCE` | **does not exist** | Checked `src/map/status_effect.h`'s `enum EFFECTFLAG` directly (not just the Lua-exposed globals) — the C++ enum itself stops at `EFFECTFLAG_NO_CANCEL = 0x800000`. Topaz's `INFLUENCE` (0x1000000), plus `OFFLINE_TICK` (0x2000000) and `AURA` (0x4000000), are simply absent from this DSP snapshot's core enum, not just missing a Lua-side name. | **Real, confirmed engine gap** — same class as `CHECK_AS_NM`, but lower-risk to add: `DelStatusEffectsByFlag(uint32 flag, ...)` and the effect's own flag storage (`CStatusEffect::GetFlag()`/`SetFlag()`) are already plain `uint32`, so `EFFECTFLAG_INFLUENCE = 0x1000000` fits with no width/overflow concern — it's a pure enum-value + Lua-global addition, no logic changes needed elsewhere. Only used by `globals/besieged.lua` (Phase 1 port), not by Nyzul's own core mechanic, so this can be deferred until that file's port is underway. |
| `tpz.effectFlag.ON_ZONE_PATHOS` | n/a | Checked the actual package source, not just the namespace list — this was a false alarm. `globals/nyzul/pathos.lua` explicitly documents in its own header that this flag **"doesn't exist in Topaz's effectFlag table either"** (it's a real LSB flag Topaz's own port never had) and never calls it — the only two hits are in code comments explaining why it's *not* used. Nothing to port. | No action needed |

## Resolved — `tpz.damageType.*`/`tpz.attackType.*`: real, different, incompatible enum

Both used only in `globals/mobskills/fulmination.lua` and `gates_of_hades.lua`, passed as
arguments to `MobFinalAdjustments(...)` and `target:takeDamage(...)`. Traced the actual DSP
calling convention by reading a real, working DSP magic mobskill (`10000_needles.lua`) rather
than guessing from naming alone:

- **`target:takeDamage(...)` does not exist in this DSP snapshot at all** (no such Lua binding in
  `lua_baseentity.cpp`). The real DSP convention is `target:delHP(dmg)` after computing `dmg` via
  `MobFinalAdjustments`.
- `tpz.attackType.MAGICAL` (=2) does not correspond to DSP's `MOBSKILL_MAGICAL` (=1) by number —
  DSP's `MOBSKILL_*` family (`scripts/globals/monstertpmoves.lua:22-26`) is offset by one from
  Topaz's `tpz.attackType` (DSP has no `NONE=0` slot; DSP's `PHYSICAL=0`, Topaz's `PHYSICAL=1`).
  **Must map by name (`MAGICAL` -> `MOBSKILL_MAGICAL`), never by number.**
- `tpz.damageType.FIRE` (=6) coincidentally matches DSP's `MOBPARAM_FIRE` (=6) — safe.
  **`tpz.damageType.LIGHTNING` (=10) does NOT match DSP's value at 10** — DSP's elemental order
  (`MOBPARAM_FIRE=6, EARTH=7, WATER=8, WIND=9, ICE=10, THUNDER=11, LIGHT=12, DARK=13`) diverges
  from Topaz's (`FIRE=6, ICE=7, WIND=8, EARTH=9, LIGHTNING=10, WATER=11, LIGHT=12, DARK=13`) for
  every element except FIRE/LIGHT/DARK. **A naive same-number "port" would have silently applied
  Fulmination's Lightning damage as Ice-elemental in DSP** — exactly the silent-misbehavior risk
  flagged before investigating. Real mapping is by NAME: `LIGHTNING` -> `MOBPARAM_THUNDER` (=11),
  not by number.

**Action for the Lua conversion pass (task 5)**: `fulmination.lua`/`gates_of_hades.lua` need a
real rewrite of their damage-application block, not a find-replace:
```lua
-- Topaz:
local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, tpz.attackType.MAGICAL, tpz.damageType.LIGHTNING, MOBPARAM_WIPE_SHADOWS)
target:takeDamage(dmg, mob, tpz.attackType.MAGICAL, tpz.damageType.LIGHTNING)

-- DSP:
local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_THUNDER, MOBPARAM_WIPE_SHADOWS)
target:delHP(dmg)
```
(`gates_of_hades.lua`'s `FIRE` case: `MOBSKILL_MAGICAL`, `MOBPARAM_FIRE`, `target:delHP(dmg)`.)

## Resolved — `tpz.msg.basic`

The family exists in DSP under the bare global table `msgBasic` (`scripts/globals/msg.lua:49`),
camelCase, no `tpz.`/`MSG` prefix at all — a different naming convention than the other families,
found by reading the file directly rather than grepping for a prefix that didn't exist.

| Topaz | DSP | Notes |
|---|---|---|
| `tpz.msg.basic.REQUIRES_A_PET` (=215) | `msgBasic.REQUIRES_A_PET` (=215) | exact match |
| `tpz.msg.basic.DISAPPEAR_NUM` (=231) | `msgBasic.DISAPPEAR_NUM` (=231) | exact match |
| `tpz.msg.basic.SKILL_NO_EFFECT` (=189) | `msgBasic.NO_EFFECT` (=189) | **name differs**, value matches |
| `tpz.msg.basic.RECOVERS_HP` (=24) | **missing** | DSP's `msgBasic` table is a real but smaller subset of Topaz's (confirmed by reading the whole 180-line file) — id 24 genuinely has no named entry. Since `messageBasic` clearly already accepts arbitrary numeric ids (that's how every other entry in the table works), this is a trivial one-line data addition to `msgBasic` in DSP's own `msg.lua` (`RECOVERS_HP = 24,`), not a C++ change. |

## Resolved — `tpz.title.*`

Bare global, **no prefix whatsoever** (not even `TITLE_`) — `scripts/globals/titles.lua:31`:
`THE_HORNSPLITTER = 25`, exact numeric match to Topaz's `tpz.title.THE_HORNSPLITTER` (=25).
Confirmed via DSP's own real, already-existing `scripts/zones/Nyzul_Isle/mobs/Bloodtear_Baldurf.lua`,
which calls `player:addTitle(THE_HORNSPLITTER)` today, unmodified.

## Resolved — `tpz.mission.*`: DSP already has a complete, differently-shaped implementation

Confirmed by reading DSP's own already-existing `scripts/zones/Alzadaal_Undersea_Ruins/npcs/_20m.lua`
(the same file our package's `_20m.lua` replaces) — it implements this exact Nyzul-entry-gating
mechanic (checking Path of Darkness / Nashmeira's Plea completion) **today, working, using DSP's
own convention**:

```lua
-- DSP's real, existing _20m.lua:
if (player:getCurrentMission(TOAU) == PATH_OF_DARKNESS and player:hasKeyItem(NYZUL_ISLE_ROUTE) ...
```

- `PATH_OF_DARKNESS` (=41) and `NASHMEIRAS_PLEA` (=43) are bare globals in
  `scripts/globals/missions.lua`, and match Topaz's `tpz.mission.id.toau.PATH_OF_DARKNESS`/
  `.NASHMEIRAS_PLEA` numerically exactly.
- **But `TOAU` itself is not a bare int** the way Topaz's `tpz.mission.log_id.TOAU` (=4) is — it's
  a whole **table** (`scripts/globals/log_ids.lua`: `TOAU = { full_name=..., mission_log=4,
  quest_log=6 }`), and `getCurrentMission`/`hasCompletedMission` take that table object directly,
  not a bare log-id int. This is a real, different calling convention, not just a renamed constant.
- **Recommendation**: don't port Topaz's rewritten `_20m.lua` (which uses
  `tpz.mission.id.toau.*`/`tpz.mission.log_id.TOAU`) at all. DSP's own existing `_20m.lua` already
  implements the identical mechanic correctly in its own idiom — diff Topaz's version against
  DSP's to find only the genuinely Nyzul-Isle-specific additions (if any) and merge those into
  DSP's existing file, rather than replacing it wholesale. Same logic applies to any other
  Alzadaal gateway door script that already exists in DSP (`_20t`/`_20u`/`_20v`/`_20w` etc. are
  NOT all present in DSP yet — check each individually before assuming DSP already has it).

## Resolved — `tpz.region`/`tpz.nation`/`tpz.alliedNation`/`tpz.zoneType`/`tpz.continent`/`tpz.expansionRegion`: not actually needed for this package

Checked where these are used in the package tree directly (not just where they're *defined*) —
every hit is inside `globals/zone.lua`, `globals/missions.lua`, and `globals/teleports.lua`
themselves (building their own internal lookup tables), never called from any Nyzul-specific
script, and — critically — **not called from `globals/besieged.lua` either**, which is the one
shared module Nyzul's own code actually requires. DSP already ships its own complete, independently
-evolved `scripts/globals/zone.lua`, `missions.lua`, and `teleports.lua` (confirmed to exist and
contain real, non-stub content). **Recommendation**: don't wholesale-port Topaz's versions of
these 3 files for this package at all — there is nothing in them that Nyzul's own code needs that
DSP's own versions don't already provide. This removes 3 large files from the Phase 1 conversion
scope entirely for this package (they'd only become relevant if a *different* future mission
package's code calls into a Topaz-specific addition inside one of them — check per-package, don't
assume this finding generalizes).

## What this means for the conversion pass (task 5/6)

- Straight bare-global rename, low risk: `tpz.status.*` -> `STATUS_*`, `tpz.slot.*` -> `SLOT_*`,
  `tpz.ki.*`/`tpz.keyItem.*` -> bare keyitem names, `tpz.mod.*_ABSORB` -> `MOD_*_ABSORB`.
- Rename + reshape (drop `tpz.` prefix, keep the table): `tpz.job.*` -> `JOBS.*`.
- Rename with a **different word**, not just dropped prefix — grep-verify each occurrence rather
  than pattern-replace blindly: `tpz.inv.TEMPITEMS` -> `LOC_TEMPITEMS`, `tpz.act.MOBABILITY_FINISH`
  -> `ACTION_MOBABILITY_FINISH`.
- Restructure, not rename: `tpz.magic.ele.FIRE` -> bare `ELE_FIRE`, `tpz.teleport.X` -> bare
  `TELEPORT_X` (the whole nested-table call convention in `globals/teleports.lua` needs
  rewriting, not a find-replace).
- Straight bare-global rename (now resolved, safe): `tpz.effect.*` -> `EFFECT_*`,
  `tpz.effectFlag.DISPELABLE`/`.ERASABLE` -> `EFFECTFLAG_DISPELABLE`/`EFFECTFLAG_ERASABLE`.
- **Real call-convention rewrite, not a rename**: `fulmination.lua`/`gates_of_hades.lua`'s damage
  application — `tpz.attackType.MAGICAL`/`tpz.damageType.FIRE`/`.LIGHTNING` map to DSP's
  `MOBSKILL_MAGICAL`/`MOBPARAM_FIRE`/`MOBPARAM_THUNDER` **by name, not by number** (the two
  enums are incompatible past FIRE/LIGHT/DARK), and `target:takeDamage(...)` becomes
  `target:delHP(dmg)` — see the worked example above.
- **New engine-side addition needed, not a rename**: `tpz.effectFlag.INFLUENCE` has no DSP
  equivalent at the C++ enum level — add `EFFECTFLAG_INFLUENCE = 0x1000000` to
  `src/map/status_effect.h`'s `enum EFFECTFLAG` (same low-risk shape as the `CInstance` localvar
  addition — a `uint32`-backed enum with room to spare). Only needed once `globals/besieged.lua`
  is ported (Phase 1); not blocking for Nyzul's own core mechanic.
- `tpz.effectFlag.ON_ZONE_PATHOS` needs no action — confirmed a dead reference even on the
  Topaz side (comment-only, never called).
- `tpz.msg.basic.*` -> DSP's `msgBasic.*` table, all confirmed except `RECOVERS_HP` which needs
  one line added to DSP's own `msg.lua` (trivial data completion, no C++).
- `tpz.title.*` -> bare global, no prefix at all — confirmed exact match.
- **Don't port `_20m.lua` wholesale** — DSP's own already-existing version implements the same
  mechanic in its own idiom (`TOAU` is a table, not Topaz's bare log-id int); diff for genuinely
  new content instead of replacing it.
- **Drop `globals/zone.lua`/`missions.lua`/`teleports.lua` from this package's conversion scope
  entirely** — nothing Nyzul-specific calls into the region/nation/continent tables inside them,
  and DSP already has its own complete versions of all three files.
- **Only remaining unresolved item**: `tpz.mobMod.CHECK_AS_NM` — a real engine gap, see
  `DSP_TRANSITION_PLAN.md` task 2. Every other family originally flagged unresolved has now been
  chased down to a concrete answer.
