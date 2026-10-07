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
- Cruor [D 5000]; Double Attack amount [D 10]
## Sallow Seymour (Indigo I, North Gustaberg, z106)
- Mud Stream - MISSING: self-centred magic dmg + Bind, Slow, Magic Def Down, Drown (-30HP/3s), maybe hate reset; used in pairs in 2nd half [J,B #7]
- Epuration - MISSING [J]
- Tremors 427 / Sandspin 426 - GUESS: existing Worm rows, retail effects (DEX Down / Accuracy Down) unverified
- Draw In - GUESS: MOBMOD_DRAW_IN=1 engine behaviour, retail trigger distance unverified
- Earth resistance trait [F] - MISSING; does-not-move [J] - not enforced
- Spell cast rate / HP gaps [D]; Cruor [D 5000]; HP 40180 [F] not applied
## Krabimanjaro / Aello (earlier slices)
- mega_scissors anim 1781 vs 188; venom_shower field effect; metal_body / scissor_guard / bubble_curtain
- Aello: see STATUS.md
## Cross-cutting
- Jade/Crimson/Indigo rift event params (14,18) observed for Jade I only; other tiers [D]
- !checknav not yet run for z95/z115/z81/z106 rift positions
- Cavernous Maw z115 id 851->884 collides with SprigganCrier
