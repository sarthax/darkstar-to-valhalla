# NPC id realign: Quicksand Caves (208) and King Ranperre's Tomb (190)

## The problem
The client takes an NPC's name, model and targetability from its own zone entity table, keyed by npc id. In these two zones the DSP `npc_list`
rows sit at ids a constant distance BELOW the client's ids for the same entities (client-generation drift):

| zone | DSP rows | offset | effect |
|---|---|---|---|
| 208 Quicksand Caves | 93 rows, 17629685..17629778 | +9 | wrong/missing names and targeting; weight doors; 7 of the 16 casket slots blocked |
| 190 King Ranperre's Tomb | 52 rows, 17555924..17555977 | +60 | same; 12 of 16 casket slots blocked |

Every row was verified by NAME against the client entity table (`mission_toolkit/ffxi_zone_database.db`, `entities`) at old id + offset before shifting.
Rows with no client counterpart were not shifted.

## Fix
- `sql/npc_id_realign_190_208.sql` renumbers the rows (descending UPDATE to avoid key collisions; guarded so a re-run is a no-op) and the matching `treasure_spawn_points` rows.
- `sql/npc_list.sql` carries the same ids for fresh imports. `sql/treasure_spawn_points.sql` updated.
- 16 casket slots per zone are now wired in both zones (923/960 overall).
- Achieve_Master / Unity_Master (208, zero-position) moved to their client ids 17629687 / 17629689. Three unnamed zero-position rows (`NPC[1ee]`,`[1ef]`,`[1f0]`) have no client entity; commented out in `npc_list.sql` and kept in `removed_rows.sql`.

## Lua adjusted (explicit ids that moved)
| file | change |
|---|---|
| scripts/zones/Quicksand_Caves/Zone.lua | `base_id` 17629685 -> 17629694 (weight doors resolve as `base_id + RegionID - 1`); door comments +15 to the real client ids; `UpdateTreasureSpawnPoint` 17629739 -> 17629748 (Treasure_Coffer); `UpdateNPCSpawnPoint` 17629761 -> 17629770 (Antican tag) |
| scripts/zones/Quicksand_Caves/mobs/Centurio_IV-VII.lua, Princeps_IV-XLV.lua, Triarius_IV-XIV.lua | `GetNPCByID` 17629738 -> 17629747 (qm6) |
| scripts/zones/King_Ranperres_Tomb/Zone.lua | `UpdateTreasureSpawnPoint` 17555955 -> 17556015 (Treasure_Chest) |

Mob ids and the rows below 17629685 / outside the ranges were not touched. Quicksand `qm1`-`qm3` look off by 8 vs the client but have scripts; left alone.

## Items shifted: Quicksand Caves (+9)
| old id | new id | script name | client name |
|---|---|---|---|
| 17629685 | 17629694 | _5s0 | Ornate Door |
| 17629686 | 17629695 | blank |       |
| 17629687 | 17629696 | _5s1 | Ornate Door |
| 17629688 | 17629697 | blank |       |
| 17629689 | 17629698 | _5s2 | Ornate Door |
| 17629690 | 17629699 | blank |       |
| 17629691 | 17629700 | _5s3 | Ornate Door |
| 17629692 | 17629701 | blank |       |
| 17629693 | 17629702 | _5s4 | Ornate Door |
| 17629694 | 17629703 | blank |       |
| 17629695 | 17629704 | _5s5 | Ornate Door |
| 17629696 | 17629705 | 507 |       |
| 17629697 | 17629706 | _5s6 | Ornate Door |
| 17629698 | 17629707 | 509 |       |
| 17629699 | 17629708 | _5s7 | Ornate Door |
| 17629700 | 17629709 | blank |       |
| 17629701 | 17629710 | _5s8 | Ornate Door |
| 17629702 | 17629711 | blank |       |
| 17629703 | 17629712 | _5sb | Ornate Door |
| 17629704 | 17629713 | blank |       |
| 17629705 | 17629714 | _5s9 | Ornate Door |
| 17629706 | 17629715 | blank |       |
| 17629707 | 17629716 | _5sa | Ornate Door |
| 17629708 | 17629717 | blank |       |
| 17629709 | 17629718 | _5sc | Ornate Door |
| 17629711 | 17629720 | _5sd | Sandstone Door |
| 17629712 | 17629721 | _5se | Sandstone Door |
| 17629713 | 17629722 | _5sf | Sandstone Door |
| 17629714 | 17629723 | _5sg | Sandstone Door |
| 17629715 | 17629724 | _5sh | Sandstone Door |
| 17629716 | 17629725 | _5si | Sandstone Door |
| 17629717 | 17629726 | _5sj | Sandstone Door |
| 17629718 | 17629727 | _5sk | Sandstone Door |
| 17629719 | 17629728 | _5sl | (blank) |
| 17629720 | 17629729 | _5sm | (blank) |
| 17629721 | 17629730 | _5sn | (blank) |
| 17629722 | 17629731 | _5so | (blank) |
| 17629723 | 17629732 | _5sp | (blank) |
| 17629724 | 17629733 | qm4 | ??? |
| 17629725 | 17629734 | Zeid | Zeid |
| 17629726 | 17629735 | Fountain_of_Kings | Fountain of Kings |
| 17629727 | 17629736 | qm5 | ??? |
| 17629728 | 17629737 | blank |       |
| 17629729 | 17629738 | NPC[1d] | (blank) |
| 17629730 | 17629739 | Moogle | Moogle |
| 17629731 | 17629740 | Moogle | Moogle |
| 17629732 | 17629741 | Moogle | Moogle |
| 17629733 | 17629742 | Moogle | Moogle |
| 17629734 | 17629743 | Moogle | Moogle |
| 17629735 | 17629744 | Moogle | Moogle |
| 17629736 | 17629745 | Moogle | Moogle |
| 17629737 | 17629746 | Moogle | Moogle |
| 17629738 | 17629747 | qm6 | ??? |
| 17629739 | 17629748 | Treasure_Coffer | Treasure Coffer |
| 17629740 | 17629749 | qm7 | ??? |
| 17629741 | 17629750 | Ramblix | Ramblix |
| 17629742 | 17629751 | Goblin_Footprint | Goblin Footprint |
| 17629743 | 17629752 | Goblin_Geologist | Goblin Geologist |
| 17629744 | 17629753 | qm8 | ??? |
| 17629745 | 17629754 | qm9 | ??? |
| 17629746 | 17629755 | qm10 | ??? |
| 17629747 | 17629756 | qm11 | ??? |
| 17629748 | 17629757 | qm12 | ??? |
| 17629749 | 17629758 | qm13 | ??? |
| 17629750 | 17629759 | qm14 | ??? |
| 17629751 | 17629760 | qm15 | ??? |
| 17629752 | 17629761 | qm16 | ??? |
| 17629753 | 17629762 | qm17 | ??? |
| 17629754 | 17629763 | qm18 | ??? |
| 17629755 | 17629764 | qm19 | ??? |
| 17629756 | 17629765 | qm20 | ??? |
| 17629757 | 17629766 | qm21 | ??? |
| 17629758 | 17629767 | qm22 | ??? |
| 17629759 | 17629768 | qm23 | ??? |
| 17629760 | 17629769 | qm24 | ??? |
| 17629761 | 17629770 | qm25 | ??? |
| 17629762 | 17629771 | qm26 | ??? |
| 17629763 | 17629772 | qm27 | ??? |
| 17629764 | 17629773 | Planar_Rift | Planar Rift |
| 17629765 | 17629774 | Planar_Rift | Planar Rift |
| 17629766 | 17629775 | Planar_Rift | Planar Rift |
| 17629767 | 17629776 | Riftworn_Pyxis | Riftworn Pyxis |
| 17629768 | 17629777 | Riftworn_Pyxis | Riftworn Pyxis |
| 17629769 | 17629778 | Riftworn_Pyxis | Riftworn Pyxis |
| 17629770 | 17629779 | Grounds_Tome | Grounds Tome |
| 17629771 | 17629780 | Grounds_Tome | Grounds Tome |
| 17629772 | 17629781 | Grounds_Tome | Grounds Tome |
| 17629773 | 17629782 | Grounds_Tome | Grounds Tome |
| 17629774 | 17629783 | Grounds_Tome | Grounds Tome |
| 17629775 | 17629784 | Grounds_Tome | Grounds Tome |
| 17629776 | 17629785 | Geomagnetic_Fount | Geomagnetic Fount |
| 17629777 | 17629786 | HomePoint#1 | Home Point #1 |
| 17629778 | 17629787 | HomePoint#2 | Home Point #2 |

## Items shifted: King Ranperre's Tomb (+60)
| old id | new id | script name | client name |
|---|---|---|---|
| 17555924 | 17555984 | Unity_Master | Unity Master |
| 17555927 | 17555987 | NPC[1d5] | (blank) |
| 17555928 | 17555988 | NPC[1d6] | (blank) |
| 17555929 | 17555989 | Tombstone | Tombstone |
| 17555930 | 17555990 | _5a0 | Heavy Stone Door |
| 17555931 | 17555991 | Tombstone | Tombstone |
| 17555932 | 17555992 | _5a1 | Heavy Stone Door |
| 17555933 | 17555993 | _5a2 | Cermet Door |
| 17555934 | 17555994 | Strange_Apparatus | Strange Apparatus |
| 17555935 | 17555995 | Destin | Destin |
| 17555936 | 17555996 | Shamonde | Shamonde |
| 17555937 | 17555997 | Trion | Trion |
| 17555938 | 17555998 | Pieuje | Pieuje |
| 17555939 | 17555999 | Claidie | Claidie |
| 17555940 | 17556000 | Curilla | Curilla |
| 17555941 | 17556001 | Rahal | Rahal |
| 17555942 | 17556002 | blank |       |
| 17555943 | 17556003 | Rochefogne | Rochefogne |
| 17555944 | 17556004 | qm1 | ??? |
| 17555945 | 17556005 | Ranperre | Ranperre |
| 17555946 | 17556006 | NPC[1e9] | (blank) |
| 17555947 | 17556007 | Moogle | Moogle |
| 17555948 | 17556008 | Moogle | Moogle |
| 17555949 | 17556009 | Moogle | Moogle |
| 17555950 | 17556010 | Moogle | Moogle |
| 17555951 | 17556011 | Moogle | Moogle |
| 17555952 | 17556012 | Moogle | Moogle |
| 17555953 | 17556013 | Moogle | Moogle |
| 17555954 | 17556014 | Moogle | Moogle |
| 17555955 | 17556015 | Treasure_Chest | Treasure Chest |
| 17555956 | 17556016 | EVENTER | EVENTER |
| 17555957 | 17556017 | Rochefogne | Rochefogne |
| 17555958 | 17556018 | Vauderame | Vauderame |
| 17555959 | 17556019 | Ramblix | Ramblix |
| 17555960 | 17556020 | Goblin_Footprint | Goblin Footprint |
| 17555961 | 17556021 | Planar_Rift | Planar Rift |
| 17555962 | 17556022 | Planar_Rift | Planar Rift |
| 17555963 | 17556023 | Planar_Rift | Planar Rift |
| 17555964 | 17556024 | Riftworn_Pyxis | Riftworn Pyxis |
| 17555965 | 17556025 | Riftworn_Pyxis | Riftworn Pyxis |
| 17555966 | 17556026 | Riftworn_Pyxis | Riftworn Pyxis |
| 17555967 | 17556027 | Grounds_Tome | Grounds Tome |
| 17555968 | 17556028 | Grounds_Tome | Grounds Tome |
| 17555969 | 17556029 | Grounds_Tome | Grounds Tome |
| 17555970 | 17556030 | Grounds_Tome | Grounds Tome |
| 17555971 | 17556031 | Geomagnetic_Fount | Geomagnetic Fount |
| 17555972 | 17556032 | blank |       |
| 17555973 | 17556033 | blank |       |
| 17555974 | 17556034 | blank |       |
| 17555975 | 17556035 | blank |       |
| 17555976 | 17556036 | HazyRune | Hazy Rune |
| 17555977 | 17556037 | Survival_Guide | Survival Guide |

## Retest
Quicksand weight doors open/close; qm6 spawns Centurio/Triarius/Princeps; Treasure_Coffer and Antican tag spawn; Tomb Grounds_Tome, Treasure_Chest, Pyxis; caskets in both zones show the right name and are targetable.
