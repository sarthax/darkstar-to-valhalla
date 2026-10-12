# Nyzul Isle Investigation & Salvage -- Research and Rebuild Scoping

Research-only scoping pass for two unbuilt end-game systems: **Nyzul Isle Investigation**
(Assault 51, zone 77) and **Salvage** (the four Remnants zones, 73-76). No code, SQL or Lua was
written for this document -- this is the "what would it actually take" writeup that has to exist
before any of it gets built.

Written 2026-09-02.

Status legend, per the convention already used in `Assault_Issue_Tracker.md`:
🔴 nothing built / core mechanic absent · 🟡 partial or scaffold only, real gap remains ·
🟢 built, not live-tested · ✅ built and confirmed working in-game.

**Standing rule applies throughout**: every number and mechanic below is cited to a real source
(BG Wiki dump via `wiki_lookup.py`, a LandSandBoat file + line, or a query against Topaz's own
`sql/`/`src/`). Where a thing could not be confirmed it is listed in
[Open questions](#open-questions--unconfirmed) rather than estimated. Nothing here should be
treated as retail-accurate just because it appears in LSB -- LSB's own comments flag several of
its values as unverified, and those are called out.

### Sources used

| Source | What it is | Trust level |
|---|---|---|
| `python wiki_lookup.py title "Nyzul Isle Investigation" --raw` | BG Wiki dump, page last edited 2026-08-25 | Reference -- player-written, but the primary retail-mechanics source here |
| `wiki_lookup.py title "<X> Remnants"` (4 pages) | BG Wiki, `Salvage (Level 75)` category | Reference |
| `D:/Claude/FFXI-Tools/LandSandBoat` (sparse checkout, expanded this session) | A real, working reference server implementation | Working code, but **not** retail ground truth |
| `C:/topaz/sql/*.sql`, `C:/topaz/src/map/**` | Our own codebase | Ground truth for "what we have" |

Sparse-checkout paths **added during this research** (previously absent, needed to answer the
"does this need C++" question): `scripts/globals/nyzul.lua`, `scripts/globals/salvage.lua`,
`scripts/globals/instance.lua`, `scripts/globals/nyzul/` (4 files), `scripts/mixins/nyzul_boss_drops.lua`,
`data/zones/nyzul_isle/`, `src/map/ai/states`.

---

## 1. Real mechanics -- Nyzul Isle Investigation

### 1.1 Correction to a common misconception, up front

The premise "boss fight every 5th floor" is **wrong** and worth stating plainly because it changes
the whole floor-loop design:

- **Progress saves every 5 floors.** BG Wiki, *Nyzul Isle Investigation*: "Progress is saved
  every 5 Floors" and "This Permanent Key Item automatically saves your <u>personal</u> Floor
  progress. Your progress is saved every 5 Floors."
- **Boss fights are every 20 floors.** Same page: "Every twenty floors, participants will be
  challenged by a Boss, including Fafnir, Behemoth, Aspid, Khimaria, Cerberus and Hydra, each
  having the chance to drop a piece of armor found inclusively in the Nyzul Isle assault. The
  pieces drop in order of feet(20), legs(40), hands(60), body(80), and head(100)."

LSB agrees: `nyzul_isle_investigation.lua:18` -- `if currentFloor % 20 == 0 then` forces
`ELIMINATE_ENEMY_LEADER` and floor layout `0`. The 20-floor cadence is the one that is real; the
5-floor cadence is the *save/token-tier* cadence.

### 1.2 Floor structure and generation

| Fact | Source |
|---|---|
| Floors 1-100, start on 1, run to 100 | Wiki: "You start on floor 1 and try to reach 100." |
| 30-minute time limit per run | Wiki: "by choosing to exit at a Rune of Transfer before 30 minutes has elapsed"; LSB `sql/instance_list.sql` row `7704` has time limit `30` |
| Floor *layout* is randomised per floor from a fixed set of arrival points | LSB `nyzul_isle_investigation.lua:13` -- `math.randomInt(1, (#xi.nyzul.FloorLayout - 1))` |
| 17 usable layouts + a dedicated boss layout (index 0) | LSB `scripts/globals/nyzul.lua:63-91` -- `FloorLayout[0]` commented "boss floors 20, 40, 60, 80", `[1]`..`[17]` live, `[18]`..`[24]` commented out |
| Per-layout mob spawn points and lamp spawn points are hand-authored tables, not procedural | LSB `scripts/globals/nyzul/floor_generation.lua` -- `lampSpawnPoints` (lines 16-194) and `layoutSpawnPoints` (lines 197-1065), keyed `[1]`..`[17]` |
| Mob *selection* is from banded pools by floor range | LSB `floor_generation.lua:1087-1127` -- `pTableEvenFloorRandomNMs` / `pTableOddFloorRandomNMs` (5 bands: 1-20, 21-40, 41-60, 61-80, 81-100), `pTableFloorRandomEntities` (17 family groups of 12 ids each) |
| Boss pools split at floor 40 | LSB `floor_generation.lua:1067-1073` -- `[40] = { BOSS_OFFSET, BOSS_OFFSET+2 }` "Original Land Kings", `[100] = { BOSS_OFFSET+3, BOSS_OFFSET+5 }` "ToAU Land Kings" |

🟡 **Unconfirmed:** the exact retail floor-layout count. LSB ships 17 active and 7
commented-out layouts, with an inline TODO at `floor_generation.lua:561` ("we need to add more
spawn points to this layout to not run out of entries"). That is LSB's own admission its data is
incomplete, not a retail number.

### 1.3 Floor objectives

Wiki, *Nyzul Isle Investigation* §Floor objectives: "Each floor will randomly assign players to an
objective. The floor objective can be checked by touching the unactivated Rune of Transfer. Once
this objective is completed, the Rune of Transfer will activate."

LSB enumerates six (`scripts/globals/nyzul.lua:33-41`), matching the wiki's list:

| # | Objective | Notes (wiki) |
|---|---|---|
| 1 | Eliminate enemy leader | An NM that "won't appear anywhere else in the game" |
| 2 | Eliminate specified enemies | Group kill |
| 3 | Activate all lamps | Three sub-variants, below |
| 4 | Eliminate specified enemy | One normal mob checking **Impossible to Gauge**; "Archaic Ramparts, Archaic Gears, and NMs do not count" |
| 5 | Eliminate all enemies | "Archaic Gears are not counted" |
| 6 | Free floor | Immediate advance |

LSB implements #4's "Impossible to Gauge" tell by setting `xi.mobMod.CHECK_AS_NM` on the chosen
mob (`nyzul.lua:266`) -- a real, reusable trick.

Free-floor rate in LSB is `math.randomInt(1, 30) == 1` (3.33%), once per run
(`nyzul_isle_investigation.lua:22-24`). 🟡 **Not confirmed against retail** -- no wiki figure found.

### 1.4 Lamp puzzle -- all three variants

The wiki confirms the three variants exactly as LSB's `xi.nyzul.lampsObjective` enum
(`nyzul.lua:43-48`: `REGISTER`, `ACTIVATE_ALL`, `ORDER`):

1. **Register** -- "All party members must touch a single lamp to register their 'certification
   code'." LSB `Runic_Lamp.lua:23-35` decrements `[Lamp]PartySize` per unique player and completes
   at zero.
2. **Activate all simultaneously** -- wiki: "There will be a total of 3 ~ 5 lamps per floor, the
   number is random each time. Lamps will turn 'on' ... ONLY when ALL lamps on the floor have been
   activated. The 'same time' window for this objective is quite long." LSB `Runic_Lamp.lua:84-106`
   holds each lamp lit for `xi.settings.main.ACTIVATE_LAMP_TIME` and checks 3/4/5-lamp completion.
3. **Activate in correct order** -- wiki: "each lamp will either stay lit, or dim and turn 'off'
   after a few seconds. The lamps that remain lit are the lamps that were activated in the right
   order." LSB `Runic_Lamp.lua:109-208` tracks a `[Lamp]lampRegister` bitmask + per-lamp
   `[Lamp]press` order, and on a full round lights correct lamps permanently and dims wrong ones
   after 10s.

The 3-5 lamp count is confirmed by both wiki and LSB. LSB's `lampRegister > 13 / > 29 / > 61`
thresholds at `Runic_Lamp.lua:116/142/168` are the "all N bits set" tests for 3/4/5 lamps.

### 1.5 Floor restrictions (sub-objectives) and Pathos

Wiki §Floor Restrictions: "A restriction can be placed on top of objectives. There are one of two
floor restrictions. They will add Archaic Gears to the floor. They aggro magic, abilities, and are
true sound."

- **"Avoid discovery by archaic gears!"** -- being aggroed applies a Pathos. "Archaic Gears can be
  claimed or defeated without penalty. If an Archaic Gear is attacked first, by a JA such as
  Provoke or Animated Flourish, or a ranged attack, you will not receive the Pathos."
- **"Do not destroy archaic gears!"** -- defeating one applies a Pathos; aggroing does not.

LSB matches with `xi.nyzul.gearObjective = { AVOID_AGRO = 1, DO_NOT_DESTROY = 2 }`
(`nyzul.lua:50-54`), rolled at `math.randomInt(1, 30) <= 5` (`nyzul_isle_investigation.lua:47`) --
i.e. ~16.7% of non-boss non-free floors. 🟡 That rate is **not** wiki-confirmed.

Wiki on the penalty: "Pathos can be various status debuffs, restrictions on magic types, job
abilities, or weaponskills, time reduction, or token reward reduction." LSB's
`xi.nyzul.penalty = { TIME = 1, TOKENS = 2, PATHOS = 3 }` (`nyzul.lua:56-61`) is exactly those
three, and `scripts/globals/nyzul/pathos.lua:10-51` is a 29-entry table of concrete effects:

- Entries 1-2: `IMPAIRMENT` power `0x01` (job abilities) / `0x02` (weapon skills)
- Entries 3-8: `OMERTA` powers `0x01`..`0x20` (songs, black, blue, ninjutsu, summoning, white magic)
- Entries 9-17: `SLOW`, `FAST_CAST`, and `DEBILITATION` powers `0x001`..`0x040` (the seven stats)
- Entries 18-29: positive effects (`REGAIN`, `REGEN`, `REFRESH`, `FLURRY`, `CONCENTRATION`, the six `*_BOOST_II`)

LSB's own comments mark several powers as confirmed (`REGEN 15`, `REFRESH 10`, `STR_BOOST_II 30`)
and one as **unconfirmed**: `pathos.lua:28` -- `SLOW power = 2000` with "needs retail data".
`REGAIN` is marked `power = 5` with the comment "confirmed 50", i.e. LSB itself disagrees with its
own annotation there. Do not port those two numbers uncritically.

### 1.6 Scoring, tokens, and progress carry-over

This is the one area where wiki and LSB agree **exactly**, which is a strong signal.

| Fact | Wiki | LSB |
|---|---|---|
| Base token award per floor starts at 200, +10 every 5 floors | "begins at 200 and increases by 10 every 5 floors" | `nyzul.lua:136` -- `floorBonus = 10 * math.floor((relativeFloor - 1) / 5)` |
| Party-size scaling: 90% for 4, 80% for 5, 70% for 6 | "(90% for a four-person party, 80% for five, 70% for six)" | `nyzul.lua:118-127` -- `rate = 1 - (partySize - 3) * 0.1` |
| Wrapping past floor 100 continues the pattern rather than resetting | "Continuing from floor 100 and back to 1 keeps the token reward pattern continuing" | `nyzul.lua:145-154` -- `getRelativeFloor` returns `currentFloor + 100` when it has wrapped |
| Starting-floor token costs: floor 1 = 0, floor 6 = 500, floor 11 = 550 ... floor 96 = 1,900 | Full table on the wiki page | `nyzul.lua:93-115` -- `floorCost`, all 20 rows match the wiki table exactly |
| Armband holder gets +10% | "the holder of the Assault Armband is then awarded a 10% token bonus" | **Not found in LSB's `nyzul.lua`** -- gap in the reference implementation |

Progress carry-over: the **Runic Disc** key item auto-saves personal floor progress every 5
floors; tokens are then spent at the initial Rune of Transfer to start from a saved floor. LSB
stores this in a char var `NyzulFloorProgress` (`nyzul.lua:190,197`) and gates the
**Runic Key** award at floor 100 on it. LSB also has a settings toggle
`xi.settings.main.RUNIC_DISK_SAVE` distinguishing "only the disk holder gets credit" (early
version) from "anyone can get a key on a 100 win" (`nyzul.lua:194-204`).

Vigil weapon drops (`nyzul.lua:305-334`, wiki §Vigil weapons): the floor-100 boss always drops 2;
one matches the Runic Disc holder's job, one is random -- and for GEO/RUN (who have no vigil
weapon) both are random. LSB implements the "always 2, one job-matched" rule but its
`baseWeapons` table (`nyzul.lua:9-31`) covers 20 jobs, WAR..SCH -- it has **no** GEO/RUN entries,
so the wiki's GEO/RUN special case is handled by omission rather than explicitly.

🔴 **Could not confirm from the wiki dump**: how token totals are persisted per character
(a currency table? a char var? `currency`/`currency2`?). LSB's mechanism was not traced during
this pass.

---

## 2. Real mechanics -- Salvage

Salvage is a *different shape of problem* from Nyzul and should not be scoped as "Nyzul with
different art". The zones are fixed-layout, hand-authored floors -- there is no floor generator at
all. The randomisation is in *which cells drop* and *which NM spawns*, not in the map.

### 2.1 Structure, per zone

| Zone | Topaz id | Floors | Boss | Source |
|---|---|---|---|---|
| Zhayolm Remnants | 73 | 🟡 not stated on the page | Battleclad Chariot | Wiki: "Battleclad Chariot is the zone's boss chariot" |
| Arrapago Remnants | 74 | **7** | Armored Chariot | Wiki: "a seven floor Salvage area with the Armored Chariot as its boss" |
| Bhaflau Remnants | 75 | **5** | Long-Bowed Chariot | Wiki: "a five floor Salvage area with the Long-Bowed Chariot as its boss" |
| Silver Sea Remnants | 76 | **5** | Long-Armed Chariot | Wiki: "a five floor Salvage area with the Long-Armed Chariot as its boss" |

Time limit: the Bhaflau page states "There is a one (1) hour time limit upon entering Bhaflau
Remnants." LSB's `sql/instance_list.sql` gives **100** (minutes) for all four zones (rows
7300/7400/7500/7600). 🔴 **These disagree** and it matters -- one of them is wrong. Needs a real
capture or a better wiki source before either is used.

### 2.2 Entry, restrictions, and the cell system

- **Entry gate**: "A Remnants Permit need to be purchased before each entry" (Arrapago page).
  Per the *Remnants Permit* page: "The NPC Zasshal will allow for 500 Assault Points from any one
  assault area to be exchanged for a remnants permit. A player may only purchase one Remnants
  Permit per Earth day."
- **The defining mechanic** is that players enter fully encumbered and must find *cells* to unlock
  their own abilities. Topaz's own existing `arrapago_remnants.lua:13-17` already applies the real
  stack on entry:
  `ENCUMBRANCE_I` (power `0xFFFF`), `OBLIVISCENCE`, `OMERTA`, `IMPAIRMENT`, and
  `DEBILITATION` (power `0x1FF`). LSB has the mirror logic in
  `scripts/globals/salvage.lua:8-53` -- `onCellItemCheck` / `onCellItemUse`, which decrement the
  relevant effect's power bitmask when a cell is used.
- 🔴 **The BG Wiki dump contains no general "Salvage" mechanics page.** `wiki_lookup.py title
  "Salvage"` returns only private-server pages (CatsEyeXI, Shiyo) plus *Golden Salvage* (the
  unrelated Ilrusi Assault). `category "Salvage (Level 75)"` returns 9 pages: the 4 zone pages and
  5 armor-set pages. So the cell list, the exact encumbrance bitmask semantics, and the
  full-unlock progression are **not confirmable from this tool** -- they would need a different
  source.

### 2.3 Objectives, progression, and rewards

Unlike Nyzul there is no per-floor objective roll. From the four zone pages, progression is:
kill your way through fixed floors, spawn optional NMs, reach the boss chariot.

- **Slot NMs** are spawned by trading a *card* from a sibling zone to a "Slot" NPC, at a fixed
  location: e.g. Arrapago -- "Hoshikazu Gi, a 100% drop from Princess Pudding which is spawned by
  trading a **Bhaflau Card** to the Slot located in the Southeast room of the second floor";
  Bhaflau -- "Demented Jalaawa ... spawned by trading an **Arrapago Card** to the Slot located in
  the small center room of the third floor"; Silver Sea -- "Don Poroggo ... spawned by trading a
  **Zhayolm Card** to the Slot located in the large North room of the third floor which appears
  after the Devilet in that room is defeated."
- **Bhaflau uses a Rampart chain** unique among the four: "Reactionary Rampart are accessed
  through Dormant Rampart which are spawned by meeting various conditions throughout the Remnant."
  LSB has a matching `Bhaflau_Remnants/npcs/Dormant_Rampart.lua` and
  `mobs/Reactionary_Rampart.lua`; Topaz has neither.
- **Boss rewards are fixed**: each boss chariot "drops exactly two pieces upon each defeat" of the
  Lv25 set for that zone (stated on the Arrapago, Bhaflau and Silver Sea pages).
- **There is no scoring/token system.** Salvage rewards are gear drops, not points -- this is the
  cleanest structural difference from Nyzul.
- 🔴 **Not found**: any wiki confirmation of a "voucher" system for Salvage. If that is a real
  mechanic it is not in this dump; do not build it on assumption.

### 2.4 LSB's Salvage implementation shape

`scripts/globals/salvage.lua` is **557 lines / 22 functions**. Notable ones, because they define
the primitives a port would need: `instanceRegister`, `onTransportUpdate`, `teleportGroup`,
`onDoorOpen`, `sealDoors` / `unsealDoors` / `openBossDoor`, `spawnGroup` / `groupKilled` /
`deSpawnStage`, `handleSlot` / `handleSocket` / `handleSocketCells`, `onTriggerCrate`,
`spawnTempChest`, and a four-function temp-box (`resetTempBoxes` / `tempBoxTrigger` /
`tempBoxPickItems` / `tempBoxFinish`).

Per-zone instance files are thin by comparison and are mostly floor/group wiring:
Zhayolm 444 lines, Bhaflau 256, Arrapago 161, Silver Sea 92.

---

## 3. Current Topaz state

### 3.1 Per-zone summary

| Zone | id | Zone.lua | IDs.lua | Instance script | mobs/ | npcs/ | Overall |
|---|---|---|---|---|---|---|---|
| Zhayolm Remnants | 73 | 28 lines | present | **none** | 1 file | **none** | 🔴 |
| Arrapago Remnants | 74 | 84 lines | present | `arrapago_remnants.lua` (147 lines) | 19 files | 22 files | 🟡 |
| Bhaflau Remnants | 75 | 30 lines | present | **none** | 2 files | **none** | 🔴 |
| Silver Sea Remnants | 76 | 30 lines | present | **none** | 1 file | **none** | 🔴 |
| Nyzul Isle | 77 | 59 lines | 106 lines | `path_of_darkness`, `nashmeiras_plea` only | 11 files | **none** | 🔴 for Investigation |

Arrapago is the outlier: it has been ported already and is a near-line-for-line match to LSB's
(`diff` shows only the expected `tpz.`/`xi.` and `require`-vs-`zones[]` idiom differences). The
other three Salvage zones have essentially nothing beyond a stub `Zone.lua` and one boss-chariot
mob file each.

For Nyzul, the two existing instances are the **story** instances (Path of Darkness = ToAU M40s,
Nashmeira's Plea) -- not the Assault. `waking_the_colossus` (which LSB has) is also absent.

### 3.2 SQL data -- what's actually there

Counts from parsing `C:/topaz/sql/*.sql` and `D:/Claude/FFXI-Tools/LandSandBoat/sql/*.sql`
(entity ids decoded as `zone = (id - 16777216) / 4096`).

**`npc_list` rows**

| Zone | Topaz | LSB | Gap |
|---|---:|---:|---:|
| 73 Zhayolm | 52 | 59 | 7 |
| 74 Arrapago | 53 | 59 | 6 |
| 75 Bhaflau | 65 | 78 | 13 |
| 76 Silver Sea | 72 | 104 | 32 |
| 77 Nyzul Isle | **176** | **176** | **0** |

**`mob_spawn_points` rows**

| Zone | Topaz | LSB | Gap |
|---|---:|---:|---:|
| 73 | 679 | 679 | 0 |
| 74 | 608 | 608 | 0 |
| 75 | 427 | 423 | -4 (Topaz has more) |
| 76 | 797 | 797 | 0 |
| 77 | **700** | **700** | **0** |

This is the single most important finding in this section: **the raw entity data is already at or
near parity.** Nyzul's 176 npcs and 700 mob spawn points match LSB exactly. Topaz's zone-77
`npc_list` already contains 5 rows named `Runic_Lamp`, 4 named `Rune_of_Transfer`, and 41 named
`Armoury_Crate`. This is not a "go find 700 mob positions" job.

(Note: LSB has since migrated Nyzul to `data/zones/nyzul_isle/{npcs,mobs}.yaml` -- 176 and 700
entries respectively -- confirming the SQL rows above are the same dataset in a newer container.
LSB's yaml splits the 41 generic `Armoury_Crate` rows into `Armoury_Crate_Casket` (4),
`Armoury_Crate_Coffer` (3), `Armoury_Crate` (3) and `Armoury_Crate_Unused` (13), and its 14
transfer runes into `Rune_of_Transfer` (8), `Rune_of_Transfer_*` (5) and
`Rune_of_Transfer_Start` (1). Topaz's rows are less differentiated -- 44 zone-77 rows are still
named `NOT_CAPTURED`.)

**`instance_entities` rows** -- this is where the real gap is

| Instance | Topaz | LSB | Gap |
|---|---:|---:|---:|
| Zhayolm (`7300`) | **0** | 387 | 387 |
| Arrapago (Topaz `65` / LSB `7400`) | 289 | 304 | 15 |
| Bhaflau (`7500`) | **0** | 343 | 343 |
| Silver Sea (`7600`) | **0** | 349 | 349 |
| Nyzul: path_of_darkness (`58`/`7700`) | 10 | 10 | 0 |
| Nyzul: nashmeiras_plea (`59`/`7701`) | 15 | 15 | 0 |
| Nyzul: waking_the_colossus (`7702`) | **0** | 12 | 12 |
| **Nyzul: nyzul_isle_investigation (`7704`)** | **0** | **560** | **560** |
| | | **Total gap** | **1,666** |

**`instance_list` rows**: Topaz has 3 relevant rows (`58` path_of_darkness, `59`
nashmeiras_plea, `65` arrapago_remnants). LSB has 8. Missing from Topaz: `zhayolm_remnants`,
`bhaflau_remnants`, `silver_sea_remnants`, `waking_the_colossus`, and
**`nyzul_isle_investigation`**.

**`mob_groups`**: 0 rows for zones 73-77 in *both* Topaz and LSB. Neither uses it here.

### 3.3 Lua globals

| File | Topaz | LSB |
|---|---|---|
| `scripts/globals/salvage.lua` | **40 lines, 2 functions** (`onCellItemCheck`, `onCellItemUse` only) | **557 lines, 22 functions** |
| `scripts/globals/nyzul.lua` | **absent** | 387 lines |
| `scripts/globals/nyzul/floor_generation.lua` | **absent** | 1,459 lines |
| `scripts/globals/nyzul/pathos.lua` | **absent** | 236 lines |
| `scripts/globals/nyzul/armoury_crate.lua` | **absent** | 291 lines |
| `scripts/globals/nyzul/vending_box.lua` | **absent** | 179 lines |
| `scripts/mixins/nyzul_boss_drops.lua` | **absent** | 31 lines |

Total Nyzul-specific Lua in LSB: **~2,583 lines** across 6 files, of which Topaz has **zero**.
Salvage globals gap: **~517 lines**.

`Nyzul_Isle/IDs.lua` in Topaz (106 lines) contains **none** of the Investigation identifiers --
no `OBJECTIVE_TEXT_OFFSET`, no `RUNIC_LAMP_OFFSET`, no `RUNE_OF_TRANSFER_OFFSET`, no
`NM_OFFSET`/`MOB_OFFSET`/`LEADER_OFFSET`/`BOSS_OFFSET`/`SPECIFIED_OFFSET`, and none of the lamp,
pathos, or floor-message text ids. Its `mob`/`npc` tables cover only Path of Darkness and
Nashmeira's Plea. LSB's is 191 lines with all of the above.

### 3.4 C++ -- what already exists (checked, not assumed)

`grep`ped `C:/topaz/src/map` directly. **The instance layer is in far better shape than expected.**

Already present and Lua-bound in `src/map/lua/lua_instance.cpp`:
`getID`, `getName`, `getZone`, `setLevelCap`, `getAllies`, `getChars`, `getMobs`, `getNpcs`,
`getPets`, `getTimeLimit`, `getEntryPos`, `getLastTimeUpdate`, `setLastTimeUpdate`,
**`getProgress`**, **`setProgress`**, **`getStage`**, **`setStage`**, **`getEntity`**,
`getWipeTime`, `setWipeTime`, `fail`, `failed`, `complete`, `completed`, `insertAlly`,
**`getLocalVar`**, **`setLocalVar`**.

`src/map/instance.h:47-58` confirms `m_progress` / `m_stage` are real members with the comment
"Tracks the progress through the instance (eg. floor #)" -- the floor counter is a first-class
engine concept here already. The `onInstanceProgressUpdate` and `onInstanceTimeUpdate` hooks both
exist in `src/map`.

Entity-side primitives that LSB's Nyzul code leans on and Topaz **already has**:
`timer`, `setPos`, `setStatus`, `setAnimationSub`, `getAnimationSub`, `resetLocalVars`,
`setMobMod`, `getInstance`, `messageName`, `messageSpecial`, `addTempItem`, `hasKeyItem`,
`updateEvent`, `addTreasure`, `delStatusEffectSilent`. `xi.mobMod.CHECK_AS_NM` exists
(`src/map`, 2 hits). Status effects `EFFECT_IMPAIRMENT (261)`, `EFFECT_OMERTA (262)` and
`EFFECT_DEBILITATION (263)` are all defined in `src/map/status_effect.h:331-333`.

---

## 4. Gap analysis

Complexity is qualitative. Anchors are real, completed work in this project, per
`documentation/Assault_Issue_Tracker.md`:
- **Small** ≈ a single data/flag correction (e.g. the `status 6 -> 0 (NORMAL)` targetability sweep).
- **Medium** ≈ Golden Salvage's mimic-architecture fix, or Breaking Morale's csid hunt + points-table fix.
- **Large** ≈ Imperial Treasure Retrieval's full AI rebuild, or Escort Professor Chanoix's
  junction-graph pathing rebuild.
- **Very large** ≈ bigger than any single completed item in that tracker.

### Bucket 1 -- New C++ needed

Deliberately conservative. Everything below was confirmed absent by grep, not assumed.

| # | Item | Evidence | Size |
|---|---|---|---|
| C1 | **Power-bitmask filtering for `OMERTA` / `IMPAIRMENT`.** Topaz treats both as blanket blocks: `src/map/ai/states/magic_state.cpp:174` is `HasStatusEffect({SILENCE, MUTE, OMERTA})` with no power read, and `ability_state.cpp:137` / `mobskill_state.cpp:41` likewise for `IMPAIRMENT`. LSB reads the power: `magic_state.cpp:371-373` (`GetStatusEffect(Omerta)->GetPower()`) and `ability_state.cpp:262,309-318` (`impairmentPower == 0x01 \|\| == 0x03`). **Both** Nyzul pathos and the Salvage cell system depend on this -- without it "no black magic" silences everything. This is the single hardest blocker. | grep, both trees | **Medium** |
| C2 | **`addEffectFlag` / `delEffectFlag` Lua bindings on a status effect object.** LSB `pathos.lua:55-58` calls all three of `delEffectFlag(DISPELABLE)`, `delEffectFlag(ERASABLE)`, `addEffectFlag(ON_ZONE_PATHOS)`. Topaz: 0 hits for either name in `src/map/lua/`. | grep | Small |
| C3 | **`EFFECTFLAG_ON_ZONE_PATHOS`.** `src/map/status_effect.h:42-71` enumerates 27 flags up to `EFFECTFLAG_AURA = 0x4000000`; there is no pathos-specific variant. Needed so pathos survives the floor transfer but is cleared on real zoning. | `status_effect.h` read in full | Small |
| C4 | **`setUntargetable` Lua binding.** LSB `nyzul.lua:352` calls `coffer:setUntargetable(false)` when spawning a treasure coffer. Topaz: 0 hits in `lua_baseentity.cpp`. (Topaz can currently only toggle `FLAG_UNTARGETABLE` via SQL `entityFlags` -- see the `topaz_entity_targetability_flag` note -- which is not runtime-settable per instance.) | grep | Small |
| C5 | **`startOptionalCutscene`.** LSB `Runic_Lamp.lua:41,52` uses `player:startOptionalCutscene(3, { [0] = 5, cs_option = { 1, 2 } })` to present the lamp's two-option menu. Topaz: 0 hits. A workaround using the existing padded `startEvent` may be viable (see `topaz_startevent_padding_required`) -- **needs investigation before this is confirmed as C++ work.** | grep | Small, **or zero** if `startEvent` suffices |
| C6 | `GetFirstID(name)` global helper. LSB's `IDs.lua` resolves offsets by entity *name* rather than hardcoded id (`Nyzul_Isle/IDs.lua:136-170`). Topaz has 0 hits for it. Strictly optional -- hardcoded ids work -- but LSB's entire Nyzul offset scheme assumes it. | grep | Small |

**Explicitly NOT needed** (checked, already present): a dedicated Nyzul or Salvage C++ manager
class. No such class exists in LSB either -- `git ls-files` shows all Nyzul/Salvage logic under
`scripts/`, and the only non-script artifact is `tools/migrations/042_salvage_ii_stored_plans.py`
(a Salvage II migration, out of scope here). Floor progression, per-instance state, dynamic
spawning, and timed restrictions are all already expressible with Topaz's existing
`setStage`/`setProgress`/`setLocalVar`/`SpawnMob`/`setMobMod` primitives. **Bucket 1 is small,
and C1 is the only genuinely load-bearing item.**

### Bucket 2 -- Lua work

| # | Item | Derived from | Size |
|---|---|---|---|
| L1 | **Nyzul floor generator** -- `floor_generation.lua` equivalent: 17 layouts × lamp spawn points + mob spawn points, 5 pools of banded NMs, 17 family groups, boss pools, `prepareMobs`. | LSB 1,459 lines | **Very large** -- bigger than Imperial Treasure Retrieval's AI rebuild, and it is ~70% hand-authored coordinate tables |
| L2 | **Nyzul core global** (`nyzul.lua`): objective enums, token maths, floor cost table, `handleProgress`, per-objective kill handlers, chest spawning, vigil drops. | LSB 387 lines | Large |
| L3 | **Pathos system**: 29-entry effect table, apply/remove/carry-over, gear-objective penalty routing. Blocked on **C1/C2/C3**. | LSB 236 lines | Medium |
| L4 | **Lamp puzzle port** -- all three variants. Logic is self-contained and the LSB implementation is complete and wiki-matching; largely a mechanical port once C5 is resolved. | LSB 211 lines | Medium |
| L5 | **Rune of Transfer** (floor menu, objective readout, advance/exit, token spend) + **Vending Box** + **Armoury Crate** (coffer/casket/appraisal). | LSB 164 + 179 + 291 lines | Medium |
| L6 | **`nyzul_isle_investigation.lua` instance object** itself -- registry/entry requirements, `pickSetPoint`, event hooks. | LSB 188 lines | Medium |
| L7 | **Nyzul `IDs.lua` rebuild** -- all offsets plus the full text table (LSB's `OBJECTIVE_TEXT_OFFSET = 7380` and every lamp/pathos/floor message). Topaz's current text table stops at the Path of Darkness dialogue and has none of these. Each id **must be verified against our own client dats** before use, per `topaz_client_id_offset` -- do not copy LSB's numbers on trust. | LSB 191 vs Topaz 106 lines | Medium |
| L8 | **Salvage globals** -- port the missing 20 of LSB's 22 `xi.salvage.*` functions (door seal/unseal, group spawn/kill/despawn, slot/socket handling, temp boxes, crate triggers). | LSB 557 vs Topaz 40 lines | Large |
| L9 | **Three Salvage instance scripts + their mob/npc script sets** (Zhayolm, Bhaflau, Silver Sea). Arrapago is already done and is the working template. Bhaflau additionally needs the Dormant/Reactionary Rampart chain. | LSB 444 + 256 + 92 instance lines, plus ~26 + ~24 + 1 mob files and ~30 + 0 + 0 npc files | Large |
| L10 | **`waking_the_colossus`** Nyzul instance (LSB has it, Topaz doesn't). Unrelated to the Assault but it is the remaining Nyzul instance gap. | LSB, 12 instance entities | Small |

### Bucket 3 -- New SQL entries

Derived from the counts in §3.2, not estimated.

| # | Item | Count | Size |
|---|---|---:|---|
| S1 | `instance_entities` rows for `nyzul_isle_investigation` | **560** | Medium (mechanical, but must be generated from a verified id list, not copied) |
| S2 | `instance_entities` rows for Zhayolm / Bhaflau / Silver Sea | **387 + 343 + 349 = 1,079** | Medium |
| S3 | `instance_entities` rows to close the Arrapago delta | **15** | Small |
| S4 | `instance_entities` rows for `waking_the_colossus` | **12** | Small |
| S5 | `instance_list` rows: `nyzul_isle_investigation`, `zhayolm_remnants`, `bhaflau_remnants`, `silver_sea_remnants`, `waking_the_colossus` | **5** | Small |
| S6 | `npc_list` gap for Salvage zones (7 + 6 + 13 + 32) | **58** | Small |
| S7 | `mob_spawn_points` | **0** for zones 73, 74, 76, 77; Topaz has 4 *more* than LSB in zone 75 | None |
| S8 | Naming/differentiation pass on zone-77 `npc_list`: 44 rows still `NOT_CAPTURED`, and the 41 undifferentiated `Armoury_Crate` rows need splitting into Casket/Coffer/Unused so the script lookup resolves (per `topaz_npc_name_drives_script_lookup`, a mismatched `name` silently kills the trigger). | ~85 rows edited | Medium |
| | **Total new/edited SQL rows** | **≈ 1,814** | |

Reminder before any of this is written: `sql/*.sql` edits have no live effect until
`py -3 dbtool.py` is run from `C:\topaz\tools` (`topaz_sql_reimport_required`).

---

## 5. Open questions / unconfirmed

Nothing below should be implemented until it is resolved against a real source.

1. 🔴 **Salvage time limit: 60 or 100 minutes?** BG Wiki (Bhaflau page) says one hour; LSB's
   `instance_list` says 100 for all four zones. Direct contradiction. Needs a capture.
2. 🔴 **Zhayolm Remnants floor count.** The other three zone pages state it explicitly (7/5/5);
   Zhayolm's does not. Its equipment chart references a "6th Floor", so ≥6, but that is inference.
3. 🔴 **No general "Salvage" mechanics page exists in the BG Wiki dump.** The cell list, the exact
   `ENCUMBRANCE_I` / `DEBILITATION` bitmask semantics, and the unlock progression are unconfirmable
   with the current tooling. Topaz's own `arrapago_remnants.lua:13-17` powers (`0xFFFF`, `0x1FF`)
   are the best available evidence and should be treated as the reference until better data exists.
4. 🔴 **Nyzul token persistence.** How tokens are stored per character was not traced. Do not
   invent a table.
5. 🟡 **Armband holder's +10% token bonus** is on the wiki but was **not found** in LSB's
   `nyzul.lua`. Would be a real, sourced addition over the reference implementation.
6. 🟡 **Free-floor rate (LSB 3.33%) and gear-restriction rate (LSB ~16.7%)** have no wiki backing.
   They are LSB's tuning, not retail data.
7. 🟡 **Pathos `SLOW power = 2000`** is flagged "needs retail data" in LSB's own comment
   (`pathos.lua:28`), and `REGAIN power = 5` carries a contradictory "confirmed 50" comment
   (`pathos.lua:39`). Do not port either number without resolving.
8. 🟡 **Retail floor-layout count.** LSB ships 17 with 7 commented out and an inline TODO that
   layout 8 lacks enough spawn points. Unknown what retail actually has.
9. 🟡 **Every Nyzul text id and entity offset** in LSB's `IDs.lua` must be re-verified against our
   own client dats via `dat-extractor` / `mission_toolkit.py`. Per `topaz_client_id_offset`, IDs
   drift between clients (+1/+8/+15 observed) and agreement between two external sources is not
   proof. LSB's `OBJECTIVE_TEXT_OFFSET = 7380` in particular is a load-bearing base for ~6
   derived message ids.
10. 🟡 **Whether C5 (`startOptionalCutscene`) is genuinely needed**, or whether a padded
    `startEvent` with the right option values reproduces the lamp menu. Cheap to test, and it
    changes whether Bucket 1 has 5 items or 4.
11. 🟡 **GEO/RUN vigil weapon handling.** Wiki states both drops are random for those jobs; LSB's
    `baseWeapons` table simply has no entry, which would index `nil`. Needs an explicit guard.
12. 🔴 **"Vouchers"** as a Salvage mechanic could not be confirmed anywhere in the wiki dump.

---

## 6. Suggested phased approach

The research does support a phasing, because the dependency graph is unusually clean: the C++ work
is small and front-loadable, the SQL is mechanical, and Salvage and Nyzul barely overlap.

**Phase 0 -- Unblock (small).**
Resolve open questions 1, 10 and 12 (cheap: one capture, one `startEvent` test, one search).
Land **C2/C3/C4** (three small bindings/flags) and settle whether **C5** is needed.

**Phase 1 -- The restriction engine (medium, highest risk).**
**C1** only: power-bitmask filtering for `OMERTA`/`IMPAIRMENT`. This is the one item both systems
sit on top of, and the only place a wrong call means rebuilding downstream Lua. Validate it against
the *existing* Arrapago instance, which already applies the real effect stack on entry and is
therefore a live test bed that needs no new content.

**Phase 2 -- Finish Salvage (large, but derivative).**
Arrapago is a working template and its raw `npc_list`/`mob_spawn_points` data is already at parity.
Port **L8** (salvage globals) and then **L9** one zone at a time, plus **S2/S3/S5/S6**. Recommend
Silver Sea first (smallest LSB instance file at 92 lines), Bhaflau last (it needs the Rampart
chain). This phase delivers three playable zones without touching any floor-generation logic.

**Phase 3 -- Nyzul skeleton (medium).**
**L7** (verified `IDs.lua`), **L6** (instance object), **S1/S5**, and a *single hardcoded floor
layout* with a *single hardcoded objective* (`ELIMINATE_ALL_ENEMIES` is the simplest). Goal is a
working floor-advance loop: enter, kill, Rune of Transfer activates, advance, floor counter
increments via the existing `setStage`. No randomisation, no pathos, no lamps.

**Phase 4 -- Nyzul objectives and lamps (medium).**
**L2** (core global, token maths, objective handlers) and **L4** (lamp puzzle). Randomise the
objective roll across all six. Still one layout.

**Phase 5 -- Floor generation (very large).**
**L1**. This is the coordinate-table grind and should be scoped as its own project, not tacked
onto Phase 4. It is the only item here comparable in scope to a full multi-week rebuild.

**Phase 6 -- Pathos, restrictions, rewards (medium).**
**L3**, **L5**, boss floors, vigil drops, Runic Disc save/restore, **L10**.

The honest read: **Phases 0-4 plus 6 are collectively comparable to a handful of the larger
Assault rebuilds already completed in this project. Phase 5 alone is larger than any of them**, and
is the reason a "just port Nyzul from LSB" framing understates the work by a wide margin.

---

## 6. Status update (2026-09-12)

This document is a **pre-build scoping pass** (written 2026-09-02, "no code, SQL or Lua was
written"). Most of the phasing above has since been overtaken by real work done in this project
after this doc was written -- `scripts/globals/nyzul/pathos.lua`, `Rune_of_Transfer.lua`,
`Runic_Lamp.lua`, and `nyzul_isle_investigation.lua` are all real, built, non-stub files now, not
the "absent" state the table in §4 describes. This section is not a rewrite of the whole doc --
just a record of what changed since, found while investigating an unrelated Assault bug
(Lebros Cavern/Periqia switch-lamp animation) that turned out to share the same model/mechanism as
Nyzul's Runic Lamp and Rune of Transfer.

- **C5 (`startOptionalCutscene`) -- resolved, not needed.** Both `Runic_Lamp.lua` and
  `Rune_of_Transfer.lua` use a bare, padded `player:startEvent(csid, ...)` instead -- confirmed
  live. No C++ binding was required.
- ✅ **2026-09-12: Rune of Transfer's real left/right menu roll found and fixed.**
  `Rune_of_Transfer.lua`'s `advanceToNextFloor()` previously rolled a fabricated 50/50 to pick
  between csid 201's `param0 = 7` (normal single-path menu) and `param0 = 27` (left/right branch).
  Decoding a user-supplied decompiled `event_201` dump plus real capture data (dialog 7347's own
  7-line bitmask structure: bit0=Not yet, bit1=Exit, bit2=Next floor, bit3=Right, bit4=Left,
  bit5=floor N, bit6=???) confirmed `7` = bits{0,1,2} and `27` = bits{0,1,3,4} -- both real, not
  invented. But the actual trigger for which one to send is **not** a coin flip: LandSandBoat's own
  source (`instances/nyzul_isle_investigation.lua`) rolls `instance:setLocalVar("menuChoice",
  math.random(1, 20))` fresh every floor (in `pickSetPoint`), and `Rune_of_Transfer.lua` checks
  `menuChoice > 1` -- a real **1-in-20 (5%)** chance of the left/right branch, 19-in-20 normal.
  Ported both pieces verbatim into Topaz's `nyzul_isle_investigation.lua`/`Rune_of_Transfer.lua`,
  replacing the fabricated 50/50. This resolves part of open question 10 below (the "is C5 needed"
  half was already answered; the menu-selection logic is now also real).
- 🟢 **2026-09-12, user-requested design change: Pathos sources now stack instead of blocking each
  other.** Previously both the per-floor 30% roll (`nyzul.lua`) and the left/right rune choice's
  50% roll (`Rune_of_Transfer.lua`) wrote to a single scalar `randomPathos` localvar, so whichever
  fired first silently blocked the other -- not a real retail behavior, just an artifact of the
  single-scalar plumbing. Reworked into a `pendingPathos` bitmask (mirroring how `floorPathos`
  already tracks currently-active effects) behind a new shared `tpz.nyzul.queuePathos(instance)`,
  which excludes anything already active *or* already queued -- both sources can now queue on the
  same floor transition and apply as two distinct, non-duplicate effects. Also **deliberately
  departs from LSB**: LSB's own left/right roll is hardcoded to the beneficial-only `18-29` range;
  per user request this was widened to the full `1-29` range so that choice can land on either a
  buff or a debuff, matching the wiki's "beneficial or detrimental" description rather than LSB's
  narrower real implementation. Not live-tested yet -- 🟢, not ✅.
- **Open question 7** below (the `SLOW`/`REGAIN` power-value discrepancies) is untouched by this
  change -- noted here only so a future reader doesn't assume the whole Pathos table was
  re-verified; only the queuing/stacking behavior around it changed.

- ✅ **2026-09-12, `!nyzulnavsweep` GM tool added and one bad coordinate found/fixed.** User asked
  how to identify unreachable floor-layout spawn points (variable doors blocking the player while
  mobs wallhack through). Built a new GM command (`scripts/commands/nyzulnavsweep.lua`) that checks
  every point in `lampSpawnPoints`/`layoutSpawnPoints` (all 17 layouts, 902 points total) against
  the zone's real compiled navmesh via `zone:checkNavPosition()`/`checkNavPath()` from each layout's
  own real anchor position. First run returned 902/902 off-mesh -- not 902 bad points, but the
  actual root cause: **Nyzul Isle had no `.nav` file in `navmeshes/` at all** (confirmed via
  `CZone::LoadNavMesh()` -- a missing/failed-to-load navmesh silently sets `m_navMesh = nullptr`,
  making every server-side nav query fail unconditionally regardless of the target zone's
  geometry). This also fully explains the original symptom: with no navmesh, mob AI pathing has
  nothing to route around (hence the wallhacking), while the player's own client-side collision
  against the real static geometry still works normally (hence real doors/walls still block them).
  User sourced a `Nyzul_Isle.nav` from another server repo and loaded it in -- re-running the sweep
  against the real navmesh found exactly **one** bad coordinate out of 902:
  `layoutSpawnPoints[17][76]` had `z = 175.5` (missing minus sign; both neighbors, idx 75 and 77,
  sit on the real `z = -175.5`). Fixed in `floor_layouts.lua`. The ported LSB spawn-point data is
  otherwise confirmed clean. (This data still isn't wired into any live mob/lamp spawning per this
  file's earlier note -- the sweep validates the coordinates themselves, not live gameplay.)

- ✅ **2026-09-12, `Runic_Lamp.lua`: duplicate Activate-lamp prompt text fixed.** User reported the
  Yes/Yes/No activate-lamp menu correctly popped up as a real interactive dialog but the same text
  ALSO spilled into the flat chat log. Root cause: `LAMP_ACTIVATE_PROMPT` (7349)'s real text is
  `"Activate the lamp?\n${selection-lines}\nYes.\nYes.\nNo."` -- a menu template meant to be
  rendered by the compiled cutscene itself (csid 3's own bytecode has a real
  `CodeQUERY`/`CodeQUERYWAIT`/`CodeIF` sequence, the same shape as other confirmed-working Yes/No
  prompts in this codebase), not printed a second time via a separate Lua `messageText()` call.
  Removed the redundant `messageText(LAMP_ACTIVATE_PROMPT)` calls (both the ACTIVATE_ALL and ORDER
  branches) -- `startEvent(3, ...)` alone now shows it once, correctly.

- ✅ **2026-09-12, confirmed real (not a bug): Free Floor has no objective dialog.** User asked
  whether a Free Floor is supposed to show an objective message. Cross-checked a fresh
  `dialog.yml` pull against `IDs.lua`'s `OBJECTIVE_TEXT` table: the 6 real per-stage objective ids
  (7360-7365) cover only 5 distinct real messages (7360/7361 are an exact duplicate, both
  "Objective: Eliminate enemy leader.") -- there is genuinely no 6th slot for Free Floor anywhere
  nearby in the real table, matching the wiki's own documented behavior ("Free floors will have no
  objective message"). No code change needed.

- ✅ **2026-09-12, boss spawn position updated.** `nyzul_isle_investigation.lua`'s
  `BOSS_FIXED_SPAWN` (used for all 6 possible floor-20/40/60/80/100 bosses via `spawnRandomBoss`)
  moved to a new user-provided real position, `(-390.5986, 0.0000, -380.1431)`. The existing
  rotation (127) was left unchanged since it was originally computed from the OLD coordinate to
  layout 16's Rune of Transfer position -- flagged to re-verify live that the boss still faces the
  rune correctly from the new spot.

- ✅ **2026-09-12, real gap found and fixed: Pathos effects never cleared on the actual "Leave
  Assault" exit.** User reported exiting via the Rune of Transfer left both beneficial and
  detrimental Pathos effects active afterward, recalling that Salvage has an equivalent
  clear-on-exit mechanic. Confirmed the real precedent: `Arrapago_Remnants/instances/
  arrapago_remnants.lua`'s `stripPathos(instance)` is called on every real exit path there (both
  mission-failure and normal completion), per that file's own comment: "Pathos debuffs are scoped
  to this zone and are not supposed to persist once you actually leave it... confirmed as the
  correct real mechanic by the user directly." `Rune_of_Transfer.lua`'s `onEventFinish` `option==1`
  branch ("Leave Assault" -- saves floor progress, awards tokens/rank points, calls
  `instance:complete()`) never called the equivalent `tpz.nyzul.removePathos(instance)`, even
  though that exact function was already correctly wired to the mid-run floor-to-floor transfer
  path (csid 95, in `nyzul_isle_investigation.lua`'s own `onEventFinish`) -- it was simply missing
  from this one final-exit branch. Added the call immediately before `instance:complete()`.

- ✅ **2026-09-12, real gap found and fixed: Shahayl missing the Assault-Orders precondition.**
  User reported Shahayl (Alzadaal Undersea Ruins' Nyzul Isle armband vendor) never offered the
  purchase menu, only the flavor-only "no business here" dialogue -- traced to the player already
  holding `ASSAULT_ARMBAND` (correct behavior, nothing left to sell), but comparing against the
  confirmed-working sibling NPC (`Daswil.lua`, Bhaflau Thickets) found a real separate gap: Daswil's
  real gate also requires the player to already hold that zone's own Assault Orders key item before
  ever offering the purchase menu (`hasKeyItem(ORDERS) and not hasKeyItem(ARMBAND)`), while
  Shahayl only checked the armband. Added the missing `hasKeyItem(tpz.ki.NYZUL_ISLE_ASSAULT_ORDERS)`
  precondition to match.
