# Test: Krabimanjaro first slice (Ordelle's Caves, zone 193)
Code: `scripts/zones/Ordelles_Caves/npcs/Planar_Rift.lua` (no SQL, no C++). Restart the map server (or reload scripts) after pulling the branch.
GM setup (in game, name = your character):
- `!zone 193` then go to a Planar Rift, e.g. `!pos -200 32 -2 193` (rift 0), `-112 0 230` (rift 1), `-150 -27.5 -200` (rift 2). Verify with `!checknav` if stuck.
- `!addkeyitem 367` (Crimson Stratum Abyssite II)  and  `!addkeyitem 1539` (voidstone 1)
- Optional: `!addcurrency cruor 5000` (shown in the menu params).
Expected: click Rift -> "You feel a mysterious energy..." -> menu (7524) -> option 1 -> "A fiend materializes from the planar rift!" and Krabimanjaro (Lv95-96) appears; voidstone KI is removed.
Not implemented yet: 30-min timer, status 475, party clearance, weakness/stagger/blitz, cruor/Pyxis rewards. The Pyxis NPC does nothing.
Report: does the menu appear? does option 1 spawn? does the client freeze (param-count/csid issue)? what happens with no KI?
Flagged invented bits: params[0]/[1] replayed from captures (RIFT-PARAM-CORRELATION.md); voidstone consumption semantics; msg 7507 param.

## v2 additions (all first-pass, untested in game)
- 30-min timer with warnings + despawn; status 475 for cleared party; per-player clearance messages.
- Kill: cruor (5500 x green%), Final Spectral Alignment, Riftworn Pyxis (placeholder item pool; options 10=take, 9=relinquish).
- Weakness (SIMPLIFIED): one random elemental-magic element per fight; each hit +alignment; blitz every 3rd hit for 15 s.
  Weapon-skill/JA/pet weaknesses, stagger and attack-down are NOT implemented.
- To test fast: lower LIMIT in mobs/Krabimanjaro.lua; cast all 8 elements of black magic to find the weakness.
