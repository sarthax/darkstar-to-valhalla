# Voidwatch: unimplemented / ambiguous mobskills, abilities, values

Running list (we will most likely need to add these). Tags: [C] capture [V] client [W] BG wiki [F] FFXIclopedia [J] wikiwiki.jp [B] BG forum [D] design guess.
Status: MISSING = no DB row/Lua, WRONG = live row differs from retail, GUESS = built but values unverified.

## Virvatuli (Jade I, W. Sarutabaruta, z115)
- Corpse Breath (skill 2511) - GUESS: dark element, damage 0.1 breath mult, Blind power 20 / 120 s are [D]. [J]
## Pancimanci (Jade I, W. Sarutabaruta [S], z95)
- Scream - WRONG: live skill 306 is MND Down, retail is Terror [J]
- Fatal Scream (Doom, 10-count) - MISSING: row commented out, anim 2131 unverified
- Dream Flower single-target hate reset - MISSING (live 301 is plain AoE sleep) [B #613]
- Cruor reward unverified [D 5000]; hundred-fists-style flurry ([B #613] unsure)
## Cottus (Crimson I, East Ronfaure [S], z81)
- Ranged attack - MISSING (occasional, plain auto-ranged) [J]
- Trebuchet - MISSING: target-centred heavy ranged, resets hate [F]
- Mercurial Strike - MISSING: self-centred magic dmg, removes shadows, repeating-digit damage (111-1111) whose digit picks the next weaponskill [F]
- Colossal Slam - MISSING: ~1000-1500 dmg + Zombie/curse that Cursna cannot remove, knockback, 15-60 s [J]
- Power Attack 666 / Impact Roar 664 / Grand Slam 665 - GUESS: Briareos-style DB rows reused; retail values/anim unverified
- Pool job 9/9 (LSB) vs [F] COR; group HP 80000 / level 80-85 are LSB, not retail
- Cruor 5000 [F stage table]; Double Attack amount [D 10]
## Sallow Seymour (Indigo I, North Gustaberg, z106)
- Mud Stream - MISSING: self-centred magic dmg + Bind, Slow, Magic Def Down, Drown (-30HP/3s), maybe hate reset; used in pairs in 2nd half [J,B #7]
- Epuration - MISSING [J]
- Tremors 427 / Sandspin 426 - GUESS: existing Worm rows, retail effects (DEX Down / Accuracy Down) unverified
- Draw In - GUESS: MOBMOD_DRAW_IN=1 engine behaviour, retail trigger distance unverified
- Earth resistance trait [F] - MISSING; does-not-move [J] - not enforced
- Spell cast rate / HP gaps [D]; Cruor 5000 [F stage table]; HP 40180 [F] not applied
## Belphoebe (Crimson III, Jugner Forest [S], z104)
- Norn Arrows - MISSING: ~1000-1500 dmg wide AoE, strips gear + gear lock (Encumberment); only candidate row in mob_skills.sql is commented out, anim 2262 unverified [J, F]
- Fixed ability order Spring->Summer->Autumn->Winter->Cyclonic Turmoil is scripted (onMobFight useMobAbility, TP>=1000, 4s gap); pool skill_list_id=0. Norn Arrows slot skipped. Untested in game
- Spring/Summer/Autumn/Winter Breeze + Cyclonic Turmoil use existing DSP skill scripts (2195-2199): Summer Breeze Regain etc. unverified
- Skills 2193 zephyr_arrow, 2194 lethe_arrows, 2200 cyclonic_torrent are NOT in retail sources for Belphoebe; left out
- Spells: -ja after each special skill, Death below 50% HP (F says 25%), rates/gaps [D]; Stun/Addle meant as AoE [J] but cast single-target
- MOD_DMGMAGIC -30, Double Attack 10 [D]; wind/light/dark resistance traits not applied
- Atmacite of Devotion KI 1806 from DSP keyitems.lua [W]; not yet client-verified. Cruor 6000 [C, F]
- Pyxis 1 position (263.1,553) [D] (no capture)
## Krabimanjaro / Aello (earlier slices)
- mega_scissors anim 1781 vs 188; venom_shower field effect; metal_body / scissor_guard / bubble_curtain
- Aello: see STATUS.md
## Cross-cutting
- Rift event params: 14,18 Jade I; 14,16 Crimson III [C]; Indigo and other tiers [D]
- !checknav not yet run for z95/z115/z81/z106 rift positions
- Cavernous Maw z115 id 851->884 collides with SprigganCrier
## Stage table / lights (voidwatch.lua)
- Stage table applied [F]: cruor = base x (100+green)/100, EXP = base x (100+yellow)/100 via addExp (no EXP message id known, silent). Weakness-hit formula and per-hit values still [D]
- Ascent cells: Planar Rift onTrade accepts cells 3434-3437 (max 3 each; bonuses blue/red +50, yellow/green +25 [F]); item ids from DSP item_basic, client check pending; no trade message ids known (silent); cells cleared when the Pyxis is claimed; wipe/timeout keeps them on the rift
- Blue/red cell bonus is per player but the Pyxis item list is shared: best bonus among participants used [D]
- Aello set to Zilart III (8000 cruor) per table; her real stage unconfirmed

## Hahava (Crimson IV, King Ranperre's Tomb z190) — first pass, untested in game
- Message ids = z95 ids − 1015 [V: z190 dialog.yml text match, 138 hits]. Capture ids == client ids in this zone.
- Skills 2714–2721 (yaksha/raksha) had no Lua; written with [D] damage multipliers/durations. Stances toggle every ~45 s [D]; Oblivion/Vengeance only <50% HP [F,J].
- Yaksha stance −50% physical taken via MOD_DMGPHYS (no separate non-dispellable effect). Raksha stance just erases effects; the "removes multiple magic effects" wording in [J] is ambiguous.
- Stance skills display "no effect" (msgBasic.NO_EFFECT) — no proper self-buff message wired.
- NOT built: very high weaponskill-damage resistance [F]; Stun resistance growth over time [F]; Vengeance's item-use block [J]; frontal-cone vs AoE targeting (all hit as AoE per skill row); "attacks without turning to face"; Petrify immunity (no bit in this engine's immunity set).
- Quad attack 25% / Regain 10 are [D] amounts for [F] wording.
- Skills 2684–2691 (dark_*) remain on pool list 472 but the pool now uses skill_list_id=0 (Lua-driven only).
- Hahava's Mail drop is item 3445 "Suit of Hahava's Mail" (material); KI 1808 not client-verified.

## Ogbunabali (Jade II / Windurst Stage II, Maze of Shakhrami z198) — first pass, untested in game
- Message ids = z95 ids − 997 [V: z198 dialog.yml text match, 138 hits]. Capture ids == client ids. Cruor 7040 in capture = 5500 × 1.28 green [C,F].
- NOT built: Gravitic Horn (<50%, frontal magic dmg ~800, hate reset, knockback, Weight) and Quake Blast (<50%, self AoE ~300, strips equipment) [F,J]. No DSP mob_skills rows and no animation evidence in the capture (killed before 50%) — need a client anim id before adding. Used as a pair (Quake Blast then Gravitic Horn) [J].
- NOT built: low-proc Enpetrify on melee [F,J]; "Does not cast magic" is satisfied by spellList 0.
- High attack speed / Store TP: only MOD_DOUBLE_ATTACK 10 + MOD_STORETP 30 [D].
- Pool 5161 moved to dedicated skill list 1164 (275 Sand Blast, 277 Venom Spray, 279 Mandibular Bite); engine picks randomly (order not documented). Sand Pit dropped (not documented for the NM).
- Drops: [F] lists Ruszor Meat (5755 Slab of Ruszor Meat), [J] lists Rift Sand instead — both unresolved; item ids otherwise checked in DSP item_basic. KI Vivid Periapt of Focus 1792 not client-verified.
- Stray rows: npc_list 17584498–17584503 (Planar_Rift/Riftworn_Pyxis at 55,260 / -193,197 / -137,377) sit in zone 197's id range; probably leftover mis-keyed LSB data. Not touched.

## Lord Asag (Jade III / Windurst Stage III, Meriphataud Mountains z119) — first pass, untested in game
- Message ids = z95 ids + 3346 [V: z119 dialog.yml text match, 149 hits]. Capture ids are −1 vs client in z119; DSP npc_list was −2, so `rekey_119.sql` moved rifts/Pyxis/fount/guide by +2 and the Moogle 307→309 (sql/npc_list.sql edited to match). Cruor base 6000 (Stage III) [C].
- NOT built: Nocturnal Servitude (no DSP mob_skills row, no animation evidence) [J,F].
- Heliovoid is an approximation: one dispel + 30 s Amnesia [F, unverified]; Nosferatu's Kiss is an AoE HP drain with damage [D]. Lua written fresh (SQL rows 2108/2109 existed without scripts).
- The "30 s Amnesia aura after TP moves" [F, unverified] is not built.
- Own skill list 1165 (2106/2108/2109/2110, random pick) and spell list 448 tiered by HP in Lua [J,F]. Silence immunity only; no dispel-immunity bit exists. Evasion/ICE+DARK res/magic-dmg cut amounts [D].
- KI Atmacite of Destruction DSP id 1812 not client-verified. Drops: Cadushi Grip 18810, Tonatiuh Axe 18539, Silver Mirror 3510 [F], ids vs DSP item_basic.

## Botulus Rex (Jeuno Stage VI / White VI, Buburimu Peninsula z118) — first pass, untested in game
- Message ids = z95 ids + 3051 [V: z118 dialog.yml text match, 96 hits]. Capture message ids skew vs client (11476 vs 11461) so client ids used. Capture NPC ids are +1 vs client; DSP npc_list was −2, so `rekey_118.sql` moved rifts/Pyxis/guide by +2 (sql/npc_list.sql edited to match). Cruor base 10000 (Jeuno stage 6) [C].
- Rift event params 2126,-1065873409,57,1302,170,0 are the capture's verbatim values for White VI; meaning unknown. Tier table is White I–VI (ids 1444-1446,1450-1452); only VI accepted.
- Mob rows 17261047/48/49 replaced (47 was a mislabeled zero-position Ketos row); group 13731 HP set to 145000 [C hptrack 142648-145430].
- Skills 2798 Gnash 'n Guttle, 2799 Sloughy Sputum, 2801 Rancid Reflux, 2802 Crowning Flatus: anim ids from [C], damage/status amounts and aoe shapes [D]. Own list 1166.
- NOT built: Chymous Reek, Just Dessert, Slimy Proposal, Bio aura (no skill id / animation evidence). Capture skills 2791/2792/2794/2795 (melee-like, msg 1/15) left out.
- Spells list 449: Aeroja/Waterja/Blizzaja/Meteor seen [C]; Firaja/Stonja/Thundaja inferred [D]; Death unverified, not added. Chainspell at <70% HP then Meteor is [W], trigger [D].
- KI Atmacite of the Shrewd 1828 and Dusky Periapt of Vigilance 1801 not client-verified (only 1828 wired as the KI drop). Pyxis capture items (Blizzaja scroll, crystal petrifact, mahogany log, ram horn) not wired; filler uses the generic pool.

## Ig-Alima (Jeuno Stage VI / White VI, Valkurm Dunes z103) — first pass, untested in game
- Message ids = z118 ids + 7 = z95 + 3058 [V]; capture ids skew +15 vs client, client ids used. DSP npc_list already matched client ids (no re-key). Cruor base 10000 (Jeuno stage 6) [C]. Rift params verbatim from capture (same as Botulus Rex).
- Mob rows 17199612/14 were zero-position group-0 rows; replaced with the 3 rift positions [V], group 13766, HP 161800 [C hptrack 161624-161973].
- Skills 2784-2790 had rows but no Lua; all 7 written. Anim ids [C/DB]; damage multipliers, effect amounts/durations [D]; effect lists [F]. Own list 1167. Melee variants 2781-2783 not built.
- Oblivion's Mantle fires right after Diluvial Wake via VW_MANTLE local var [F]. Crippling Rime hate reset [B]; used Slow as filler status [D].
- Spells list 450: Blaze Spikes 249 [C]; Ice 250 / Shock 251 standard ids [D]. NOT built: Dread Spikes at low HP, ice spell casting [B], high auto-Regen, extreme MDB, bind/stun-on-hit [F]. Stun resistance growth not built.
- KI Atmacite of the Valiant 1827 and Vivid Periapt of Vigilance 1800 not client-verified (only 1827 wired). Pyxis capture items (Curaga V scroll, petrified log, mind potion, elixir) not wired.

## Ildebrann (Zilart Stage I / Ashen I, Ifrit's Cauldron z205) — first pass, untested in game
- Message ids = z118 ids − 3939 = z95 − 888 [V: z205 dialog.yml text-checked on 12 ids]. Capture NPC ids are +1 vs client for rifts (capture rift 17617263 = idx 1, csid 6001); DSP npc_list already matches client, no re-key. Mob ids equal client. Rift params 2126,-1065873409,63,1302,170,0, KI 1447 (Ashen Stratum Abyssite) [C]; Ashen I-III (1447-1449) all accepted [F].
- Mob/pet row layout: every 3rd row is Ildebrann (166/169/172), +1/+2 are Hraun Dragons. HP 129300 [C] (a second kill read ~116800, unexplained); pets 15900 [C].
- Cruor/EXP from ZILART stage 1 {5000,7000} [F]; capture cruor reading not usable.
- Skills [C ids]: Fiery Breath 1281, Touchdown 1282, Inferno Blast 1283, Tebbad Wing (air) 1284; Absolute Terror 1285 [F, not seen in capture]; Baleful Roar 2696 anim 660 [C] (new row; Lua = dispel-all, conal/aoe shape [D]). Existing Tiamat-family Lua reused for the first five; own list 1168. Skill 1278 melee fire variant and Spike Flail (hate from behind) not built.
- Spells list 451: Firaga IV 177, Fire V 148, Firaja 496 [C]; rates [D].
- Hraun Dragon summon at 100/75/50/25% HP (only missing pets) [B #1004]; "resummon a few minutes after defeated" [F] not built separately.
- NOT built: flying state while pets live (immune to melee, fire-element auto attacks [F]), 40-50 yalm AoE range when grounded, regen +1%/min [B], Absolute Terror duration tuning, pets' own dragon ability list (uses pool list 87 as-is).
- Drops [F]: Glassblower's Belt 10816, Gram 19173, Silver Mirror 3510, ids vs DSP item_basic. KI Vivid Periapt of Adaptability DSP id 1798 [F name], not client-verified. Pyxis capture params (902,4145,798 / 653) not wired.

## Lancing Lamorak (Jeuno Stage IV / White IV, West Ronfaure z100)
- **ID offset risk:** client npc ids are DB+33 in z100 (rifts 587-589, Pyxis 590-592) vs the capture's DB+1; followed the client per the standing rule via `rekey_100.sql`. Verify the rifts/Pyxis respond in game.
- **Shadows:** [F] "5+ shadows after any TP move or spell". Built for spells and Rhinowrecker only (3 Copy Images, count [D]). Shadows after Rhino Attack / Power Attack not built (shared beetle skill scripts, left untouched).
- **Rhinowrecker / Power Attack / Rhino Attack:** damage multipliers [D]; Rhinowrecker knockback and conal shape not verified (anim 1986 [C]).
- **Spell choice/rates:** [D]. Aero V 158, Aeroga IV 187, Aeroja 498, Silencega 359 from [F].
- **Drops:** only Athos's Boots, Blithe Mantle, Brego Gloves, Riftsand wired; scroll/material/medicine pools not built. Pyxis capture items (coral fragment, darksteel ingot, elixir, ram horn) not wired.
- Rift positions need `!checknav`; mob 17187289 row in `sql/mob_spawn_points.sql` is superseded by the slice SQL.

## Smierc (Jeuno Stage V / White V, Tahrongi Canyon z117)
- No re-key needed: DB npc ids already equal client ids (rifts 17257088-90, Pyxis 91-93). Capture ids are +3 vs client.
- **Quick Magic:** [F] "Quick Magic Meteor"; the ability id is unconfirmed, so Meteor is cast normally from the spell pool, with no Quick Magic buff.
- **Cloudscourge:** id 2824, anim 1993 [C]; damage, element and Terror duration [D]. Melee uses the shared skill list only via its own list (no extra skills).
- **Spell choice / -ja threshold (<30% HP):** [D].
- **Drops:** only Athos's Gloves, Devourer, Praeco Doublet, Riftsand wired; scroll/material/medicine pools not built. Pyxis capture items (Wind Carol II scroll, darksteel ingot, others) not wired.
- Cruor in capture was 16590 (base 7000 [W] plus bonuses); not reconciled.
- Rift positions need `!checknav`.

## Stachysaurus (Jeuno Stage V / White V, La Theine Plateau z102)
- **Re-key:** DB block 689-696 shifted -1 to client ids via `rekey_102.sql` (Mogball/Mog-Tablet moved too to avoid collisions). Fount/Guide ids left untouched (DB and client differ by 1 in the other direction); not used by VW scripts.
- **Clobber vs Crippling Slam:** capture shows Batterhorn 2099 (anim 1437) and Clobber 2100 [C]; the wikis list "Crippling Slam" (severe damage + Paralyze). Mapped to Clobber unconfirmed; the DB row's anim is 1436 vs capture 1438, left untouched (shared Wivre row). Both scripts are new (`batterhorn.lua`, `clobber.lua`); multipliers/Paralyze power [D].
- **Drops:** only Ogier's Gauntlets, Brego Helm, Hreysti Helm, Riftsand wired; scroll/material/medicine pools and Pyxis capture items (crystal petrifact, mythril ingot, petrified log) not built.
- Rift positions need `!checknav`; cruor in capture 16590 vs 7000 base not reconciled.
## Kholomodumo (Crimson III, Jugner Forest [S], z82)
- Accursed Armor (2390) - GUESS: curse spikes via MOD_SPIKES 4 for 60 s [D]; skill id/anim 1663/msg 101 [C]. Curse potency/duration come from the engine (power 15, 180 s)
- Amnesic Blast (2391) - GUESS: anim 1664, ~80 dmg [C]; dark-element magic, 2x weapon dmg, Amnesia 30 s, cone shape [B] are [D]
- Ecliptic Meteor (2586) - GUESS: anim 1684, ~103 dmg [C]; 6x weapon dmg, AoE radius 20 [D]; used only below 50% HP [B #614, C]
- Meteor - now a SPELL (218) cast from Lua after Thunderbolt below 50% HP (80% chance [D]) per JP wiki; needs live test (castSpell with no spell list)
- Thunderbolt 629 - GUESS: reused existing row (anim 373 not verified against this NM)
- Spell list - none: no spells in a ~2 min capture [C]; retail list unknown
- Mob spawn row 17113827 was (0,0,0); now rift-1 position (275,-0.5,564) [D], needs !checknav
- Drops Genesis Shield / Genesis Locket [B #292], rates [D]; silver mirror + crystal petrifact come from the generic pool as in the capture
- Atmacite of Persistence KI id 1807 (DSP keyitems.lua), client-id check pending; HP 60436 from hptrack estimate [C]

## Melancholic Moira (Indigo III, Pashhow Marshlands [S], z90)
- The capture (Raguza 2021.03.27, ~80 s kill) shows NO mob TP moves, so her whole skill set comes from forum/LSB, not [C]
- Bad Breath (2392) - GUESS: fixed 600-800 damage [B #106], radial [B #611]; ailment set copied from the Morbol bad_breath.lua [D]; shared Morbol 319 is HP-scaled so unusable here
- Tainting Breath (2575) - GUESS: id/anim 63 from a commented LSB row; 300-500 damage + Disease 60 s are [D]
- Impale 316 / Vampiric Lash 317 - kept from the LSB Morbol pool list [LSB], not reported for Moira; Sweet Breath 320 dropped
- "EBB" [B #106, #611] - NOT BUILT: AoE, possibly NPC self-targeted; no resolved name or skill row
- Spell list - none: no casting reported
- Spawn rows all non-zero and next to their rifts; no edits. Rift params 6,0 [C] (Crimson uses 14,16)
- Drops: Appetence Crown (rate [D]); Silver Mirror / Black Rock / Darksteel Ingot [B #106, #1357] come from the generic pool only
- Atmacite of Incursion 1810: client id verified (KI-VERIFICATION.md). HP 50796 from hptrack estimate [C]; cruor 12300 = 6000 x 205% green [C]
- Message ids: z90 dialog.yml, each text-checked (z82 - 566); the capture's 8087/8175 are the +1 capture offset of 8086/8174
- Not tested in game

## Akupara / Voidwrought (2026-10-07)
- Testudo Tremor anim id 2329 unverified; Tortoise Song uses the Adamantoise dispel-all Lua
- Voidwrought: shock spikes are always on (retail: while casting); Ballistic Kick percent-HP damage and equipment strip approximated (physical hit + Encumbrance); Turbine Hurricane is DSP row turbine_cyclone
- Voidwrought third spawn position (-480,-0.5,760) is a design guess; level/HP for both unknown
