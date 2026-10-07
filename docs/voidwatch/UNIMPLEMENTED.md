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
