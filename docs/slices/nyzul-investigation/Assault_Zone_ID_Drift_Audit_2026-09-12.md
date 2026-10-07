# Assault Zone ID Drift Audit — 2026-09-12

Cross-checked dialog/event/key-item ids in this project's Assault zone `IDs.lua` files against
fresh ground truth extracted directly from the real client via `mission_toolkit.py` (dat-extractor
+ xi-tinkerer, not any external/possibly-different-client-version source). Triggered by an
unrelated investigation into Lebros Cavern/Periqia switch-lamp animation values that turned up a
pattern of unverified ids elsewhere in the project.

**Zones checked**: Aht Urhgan Whitegate, Lebros Cavern, Periqia, Mamool Ja Training Grounds, Ilrusi
Atoll, Leujaoam Sanctum, Nyzul Isle.

**Method**: for each zone, extracted a fresh `dialog.yml`/`events.yml` via `mission_toolkit.py`,
then cross-referenced every `IDs.lua` `text` entry's inline comment (the expected real text) against
that zone's real dialog table. Key items referenced by assault scripts were checked individually via
`id_bridge.py` (name-based lookup against Topaz's own live tables).

---

## Corrected ids

### Ilrusi Atoll — Lost and Found (mission 47), Tian Tian hint-chain

File: `scripts/zones/Ilrusi_Atoll/IDs.lua`

The entire chain was a uniform **+1** drift — the original values were read directly off a packet
capture's decoded NPC Chat lines and were never cross-checked against a real dialog table dump (this
block's own prior header said as much). Every id below is now dat-extractor-confirmed by exact text
match.

| Constant | Before | After |
|---|---:|---:|
| `TIAN_TIAN_GREET` | 7574 | 7573 |
| `TIAN_TIAN_WAIT` | 7575 | 7574 |
| `TIAN_TIAN_EXAMINING` | 7576 | 7575 |
| `TIAN_TIAN_COULD_WAIT` | 7577 | 7576 |
| `TIAN_TIAN_IMAGE_COMING` | 7578 | 7577 |
| `EYE_OF_ZAHAK_FOUND` | 7580 | 7579 |
| `TIAN_TIAN_VERY_CLOSE` | 7588 | 7587 |
| `TIAN_TIAN_SOMETHING_NEARBY` | 7589 | 7588 |
| `TIAN_TIAN_MAYBE_HERE` | 7590 | 7589 |
| `TIAN_TIAN_TRY_ELSEWHERE` | 7591 | 7590 |
| `TIAN_TIAN_NOTHING_HERE` | 7592 | 7591 |
| `TIAN_TIAN_VALUABLE_HINT` | 7593 | 7592 |
| `TIAN_TIAN_NO_HINTS_YET` | 7597 | 7596 |
| `TIAN_TIAN_EXCITED` | 7602 | 7601 |

### Mamool Ja Training Grounds — Azure Ailments (mission 19), Garjham

Files: `scripts/zones/Mamool_Ja_Training_Grounds/IDs.lua`,
`scripts/zones/Mamool_Ja_Training_Grounds/npcs/Garjham.lua`

Three distinct, unrelated bugs in the same small block (raw values were from an older capture/client
pairing, already flagged unconfirmed in the file's own header):

| Constant | Before | After | Nature of the bug |
|---|---:|---:|---|
| `AZURE_AILMENTS_INTRO` | 136 | 7638 | Was wired as a `startEvent()` CSID — but no csid 136 exists anywhere in this zone's real event table. The real content is plain dialog text, not a cutscene. |
| `AZURE_AILMENTS_INTRO2` | *(did not exist)* | 7639 | Second real line ("To gather proper data...") that was never wired at all — the old single `INTRO` id's comment had folded both lines together as if they were one message. |
| `AZURE_AILMENTS_REMINDER` | 7648 | 7640 | Old id's real text was a different, unrelated closing line ("And that is all we require from you today..."). |
| `AZURE_AILMENTS_CHECK` | 7654 (single id) | per-effect table: `DISEASE=7641, SLOW=7642, AMNESIA=7643, BIO=7644, STR_DOWN=7645, ATTACK_DOWN=7646, EVASION_DOWN=7647` | Old single id's real text was yet another unrelated line ("no longer any carriers in the vicinity..."). The real mechanic has 7 distinct, individually-worded lines (one per ailment), not one shared template — restructured from a scalar id into a table keyed by the same `tpz.effect` ids `Garjham.lua`'s `TARGET_EFFECTS` list already uses. |

**Code change accompanying this fix** (`Garjham.lua`): `onTrigger`'s intro branch now calls
`player:showText()` twice (once per real line) instead of `player:startEvent()`; the ailment-check
branch now indexes `ID.text.AZURE_AILMENTS_CHECK[found]` instead of calling a single shared id.

---

## Checked and confirmed clean (no changes)

- **Aht Urhgan Whitegate**: all 60 `text` ids verified correct against a fresh dialog dump.
- **Lebros Cavern, Periqia, Leujaoam Sanctum, Nyzul Isle**: dialog ids check out. A number of entries
  were initially flagged by the audit script but turned out to be false positives — the comment
  abbreviates a real template placeholder (e.g. `<item>`, `<number>`, `[day/days]`) differently than
  the real client's own `${item-singular}`/`${number}`/`${choice-plurality}` token, not a real content
  mismatch.
- **Key items**: only one key item (`RUNIC_DISC = 879`, Nyzul Isle) is referenced by any of these
  zones' assault scripts. Confirmed correctly bridged via `id_bridge.py` (matches the real capture
  evidence already found this session for `Rune_of_Transfer.lua`'s csid 94 params).
- **Unused, left as-is**: `CARRIED_OVER_POINTS`, `LOGIN_CAMPAIGN_UNDERWAY`, `LOGIN_NUMBER` are
  flagged as mismatched in every zone's shared header block (a boilerplate section, not
  zone-specific), but confirmed via grep to be referenced by zero zone scripts — no live impact.

## Not yet covered

- CSID/event drift beyond the one case found above (`AZURE_AILMENTS_INTRO`'s bogus csid 136) — no
  systematic per-zone event-table audit was run.
- Item (non-key-item) reward drift (lockbox contents, etc.) — `id_bridge.py drift-report item`
  exists for this but wasn't run zone-scoped for these missions.

---

## Registered npc/mob id audit (follow-up, same date)

Separate pass checking whether the entity ids *themselves* (not their dialog) have drifted —
cross-referenced every real client entity name (`entities.yml`, per-zone) against our own
`sql/npc_list.sql`/`sql/mob_spawn_points.sql` `polutils_name` field, id-for-id, for the same six
Assault zones plus Aht Urhgan Whitegate.

**Result: no drift in any Assault instance zone.** All 2,360+ registered entities checked across
Ilrusi Atoll, Lebros Cavern, Periqia, Mamool Ja Training Grounds, Leujaoam Sanctum, and Nyzul Isle
matched their real client name exactly — **zero mismatches**. This tracks with this project's
history: extensive npc/mob id-correction work already happened in these zones across earlier
sessions (see `Assault_Issue_Tracker.md`), so the entity-identity layer was already solid going into
this audit; the drift this session found was specifically in the dialog/text-id layer (above), not
in what id maps to which entity.

**Aht Urhgan Whitegate did turn up 6 mismatches**, all clustered in one narrow range:

| Real id | Ours (wrong) | Real name |
|---|---|---|
| 16982641 | Unity Master | Linkshell Concierge |
| 16982642 | Survival Guide | Chat Manual |
| 16982643 | Resume Point | Unity Master |
| 16982645 | ??? | Resume Point |
| 16982647 | Kagero | ??? |
| 16982652 | ??? | Iroha |

None of these 6 ids are referenced by any script in the codebase — zero live gameplay impact.
Given Whitegate's Unity system is a later content-era addition than this project's ToAU-era target,
this is more likely a content-version mismatch than a real drift bug, and wasn't pursued further
since nothing depends on it. Flagged here rather than silently dropped in case a future session
wires something to this id range.

---

## Alzadaal Undersea Ruins (zone 72) — follow-up audit, 2026-09-12

User reported "some doors may have wrong object associated, some doors give wrong message, some
dialog ids seem off" — triggered a full re-pull of this zone's ground truth (fresh
`dialog.yml`/`entities.yml`/`events_disasm.txt` via `mission_toolkit.py Alzadaal_Undersea_Ruins`)
and cross-check against `scripts/zones/Alzadaal_Undersea_Ruins/`.

### Entity identity: clean, no drift

Every mob/npc id in `IDs.lua` (`NEPIONIC_SOULFLAYER`, `COOKIEDUSTER_LIPIROON_PH`, `OB`,
`CHEESE_HOARDER_GIGIROON`, `ARMED_GEARS`, `WULGARU`, `RUNIC_PORTAL_NORTH/SOUTH`) matches its real
client name exactly against a fresh `entities.yml` pull. All 4 "Gilded Gateway" door pairs and all
25 "Gilded Doors" rows in `npc_list.sql` also match their real client names exactly — the "wrong
object associated" symptom is not an id-to-entity mismatch.

### Real bug found: one door in the 4-gateway Remnants family had NO script at all

`events_disasm.txt` confirms the 4 "Gilded Gateway" doors' real compiled events: entity 17072227
(`_20t.lua`) = csid 410 (Silver Sea), 17072229 (`_20u.lua`) = csid 408 (Arrapago), 17072233
(`_20w.lua`) = csid 409 (Bhaflau) — all three already correctly wired. The 4th, entity 17072231
(npc name `_20v`, real csid **407**), had **no Lua file at all** — clicking it only ever played the
default door animation with no cutscene, the exact same bug class already found and fixed on
`_20w.lua` (Bhaflau) in an earlier session. Built `_20v.lua` for real, modeled on `_20w.lua`:
targets `tpz.zone.ZHAYOLM_REMNANTS` (73), `createInstance` offset 61 (matches
`instance_list.sql`'s real `zhayolm_remnants` row, id 62, same "base id - 1" relationship every
other door in this family has to its own real instance row).

Also found and fixed a documentation-only error while cross-checking this family: `_20t.lua`'s own
header comment mislabeled it "(Arrapago)" with Arrapago's real position — harmless at runtime (the
engine wires `onTrigger` by `npc_list.name` = filename, not by header text), but corrected to
"(Silver Sea)" with entity 17072227's real position for accuracy.

### Real bug found: entire zone-specific dialog table off by a uniform +1

Every `ID.text` constant in this zone's `IDs.lua` except `NOTHING_HAPPENS` (119) and
`ITEM_CANNOT_BE_OBTAINED` (6383) was off by exactly **+1** versus the real client dialog table —
confirmed by reading the actual text at both the claimed id and `id - 1` for the entire block. This
had real, live gameplay impact, not just a documentation mismatch:

| Constant | Before (wrong) | After (real) | What the wrong id actually said |
|---|---:|---:|---|
| `ITEM_OBTAINED` | 6389 | 6388 | "Obtained \<number\> gil." (the gil message, not an item message) |
| `GIL_OBTAINED` | 6390 | 6389 | Same text either way (adjacent duplicate), corrected for consistency |
| `KEYITEM_OBTAINED` | 6392 | 6391 | **"Lost key item: \<keyitem\>."** — the opposite of what it's used for in `Shahayl.lua`/`Zone.lua` (`ASSAULT_ARMBAND`/`ASTRAL_COMPASS` pickups) |
| `CARRIED_OVER_POINTS` | 7000 | 6999 | Unused boilerplate (same as other zones' audits), no live impact |
| `LOGIN_CAMPAIGN_UNDERWAY` | 7001 | 7000 | Unused boilerplate |
| `LOGIN_NUMBER` | 7002 | 7001 | Unused boilerplate |
| `MOVE_CLOSER` | 7210 | 7209 | "This gate guards an area under Imperial control." (used by `_20c.lua`/`_20d.lua`) |
| `IMPERIAL_CONTROL` | 7211 | 7210 | "“Azouph Isle Staging Point.”" (wrong zone's staging line) |
| `STAGING_POINT_NYZUL` | 7217 | 7216 | "Enter the gate?\n...Yes.\nNo." — a menu prompt, not the staging-point line |
| `CANNOT_LEAVE` | 7221 | 7220 | "Attuning yourself to this runic portal will open a path..." |
| `RESPONSE` | 7230 | 7229 | "You're a mercenary from Salaheem's Sentinels?" (used by `Runic_Portal.lua`) |
| `DEVICE_MALFUNCTIONING` | 7246 | 7245 | A `DEBUG:` GM-only line (used by `blank_lamp.lua`) |
| `NOTHING_OUT_OF_ORDINARY` | 7426 | 7425 | "Now is not the time for that!" (used by `blank_transformations.lua`) |
| `CANNOT_ENTER` | 7442 | 7441 | "This area is fully occupied." (used by every Remnants gateway script) |
| `AREA_FULL` | 7443 | 7442 | "Could not connect to server." |
| `MEMBER_NO_REQS` | 7447 | 7446 | Slightly different real wording ("Not all of your party members...") |
| `MEMBER_TOO_FAR` | 7451 | 7450 | "One or more party members are carrying imbued items." (used by `_20m/_20t/_20u/_20w.lua`) |
| `MEMBER_IMBUED_ITEM` | 7452 | 7451 | "You are carrying imbued items." (singular, wrong case) |
| `IMBUED_ITEM` | 7453 | 7452 | Level-requirement message, unrelated |
| `MYTHIC_REQUIRED` | 7455 | 7454 | "You can only participate once per Earth day." |
| `HEADY_FRAGRANCE` | 7729 | 7728 | "Minute glittering fragments are scattered all over..." (used by `qm2.lua`) |
| `SLIMY_TOUCH` | 7748 | 7747 | "A stifling stench pervades the air..." (used by `qm1.lua`) |
| `DRAWS_NEAR` | 7759 | 7758 | A key-item-pulsate line, unrelated (used by `qm1.lua`/`qm2.lua`) |

Every constant corrected in `IDs.lua`. This directly explains the user's "doors give wrong message"
and "dialog ids seem off" reports — `_20c.lua`/`_20d.lua` (the Nyzul Isle staging doors),
`Runic_Portal.lua`, `blank_lamp.lua`, `blank_transformations.lua`, `qm1.lua`/`qm2.lua`, and every
Remnants gateway script (`_20m/_20t/_20u/_20v/_20w.lua`) all consume one or more of these ids
directly.
