# Voidwalker NM skills: gating and gap analysis

Generated 2026-10-16 from the live DB (`mob_pools.skill_list_id` -> `mob_skill_lists` -> `mob_skills`, and the Lua present in `scripts/globals/mobskills/`) against FFXIclopedia, BG Wiki (local dump) and the JP wiki (no Voidwalker pages exist, see DATA-SOURCES). Colour/Black tier NMs only; clear-tier mobs use stock family lists.

## Why gating is needed

Every Voidwalker NM has its own `mob_pools` row, so `skill_list_id` can be changed per NM without touching other mobs. The skill *rows* and their Lua are shared (for example `acid_mist` is on 6 lists, `recoil_dive` on 2, `metallic_body` on 6). Two consequences:

1. **Different skill set**: give the NM its own list (like Blobdingnag 9001 and Orcus 9002). No Lua gating is needed.
2. **Same skill, different effect** (undispellable Metallic Body, Acid Mist hate reset and shadow wipe, TP-free Recoil Dive): the shared Lua must branch on a flag, like Voidwatch's `vwBuffActive` / `VW_NO_REBUFF`. Nothing sets such a flag for Voidwalker yet. Proposal: `voidwalker.onMobSpawn` sets `mob:setLocalVar("VWK_NM", 1)`, and a global `vwkNM(mob)` helper is checked in the skill Lua. It stays false for ordinary mobs, so shared scripts are unchanged for them.

Free list ids: 9003 and up (9001/9002 are used; verify with the collision tool before use).

## Missing or broken skills (needs work)

| NM (pool) | Problem | Detail |
|---|---|---|
| **Yilbegan** (4736, list 470) | **All 12 skills have no Lua** | dexter_wing, sinister_wing, chaos_blast, abyssic_buster, dancing_tail(+v2), chilling_roar(+v2), soul_douse(+v2), dark_star(+v2) = ids 2519-2530, no files in mobskills/. Wiki: Soul Douse (frontal), Dancing Tail (rear), Sinister Wing (left), Dexter Wing (right), Chaos Blast and Dark Star (any), stance-dependent damage resistance, HP cloak revealed after Chaos Blast. Highest priority: the Black-tier NM currently cannot use TP moves. |
| **Lord Ruthven** (7114, list 252) | 2 of 6 skills no Lua, 2 wiki skills missing | decollation (2107) and eternal_damnation (2111) have no Lua. **Dirty Breath** (Zombie, reveals HP) and **Minax Glare** (Terror gaze + Defense Down) have no DB row. nocturnal_servitude (2112) exists but wiki says Ruthven does NOT use it, so it must stay off the list. |
| **Verthandi** (7135, shared list 195) | Norn Arrows missing | Row 2518 exists (anim 1581, same as Zephyr Arrow) with no list and no Lua. Wiki: AoE, long range, knockback, Encumbrance, reveals HP, repeats until it connects. Needs a Verthandi-only list. |
| **Krabkatoa** (7112, list 77) | Mega Scissors and Venom Shower not on its list | Rows 2513 and 2512 and their Lua exist (list 1159, Voidwatch). Wiki: Mega Scissors replaces Big Scissors (cone, resets enmity); Venom Shower (AoE poison + Defense Down, then a Plague aura). List 77 is the stock Sunderclaw crab list (shared by 88 pools). |
| **Shoggoth** (7120, list 139) | Petrogaze missing | `petro_gaze.lua` exists but there is no DB row. Wiki lists Hex Eye and Petrogaze; death_ray and catharsis on the list are not mentioned by the wiki. |
| **Chesma** (7102, list 71) | 3 of 4 wiki skills missing | Petrifactive Breath and Frenzied Rage: no DB row or Lua. Charged Whisker exists (3416) but only on list 494. blaster is present. chaotic_eye is on the list but not in the wiki. |
| **Dawon** (7103, list 242) | Disorienting Waul missing | No DB row or Lua. Claw Cyclone is present. |
| **Farruca Fly** (7105, list 113) | Somersault missing | Wiki: Cursed Sphere, Venom, Somersault. Rows 318 and 1732/1922 exist; list 113 has only cursed_sphere and venom. |

## Same skill, different effect (needs `VWK_NM` gating in the skill Lua)

| NM | Skill / mechanic | Wiki behaviour | Where to implement |
|---|---|---|---|
| Krabkatoa | metallic_body | Undispellable, about 1000 HP Stoneskin | `metallic_body.lua` |
| Krabkatoa | bubble_curtain / scissor_guard | Shell (-50% magic damage) / Defense +100% | already stock; verify numbers |
| Krabkatoa | venom_shower | Plague aura afterwards | `venom_shower.lua` |
| Capricornus | Mighty Strikes | At 80/60/40/20% HP and below 15%; **Recoil Dive spammed with no TP while active** | `onMobFight` HP gate in the NM script, plus `recoil_dive.lua` (conal, hate reset, ignores Blink) |
| Capricornus | intimidate | Overwrites Haste, 15 s, resets enmity | `intimidate.lua` |
| Capricornus | splash_breath | Temporary Double Attack boost afterwards | `splash_breath.lua` |
| Lamprey Lord | acid_mist | Only TP move; longer ready time, wipes shadows, resets hate, Paralyze aura if stunned. Blood Weapon JA at random | own list with acid_mist only, plus `acid_mist.lua` gate |
| Yacumama | Hundred Fists | At 20% HP intervals, then more often below 20%; speed 50% during it | `onMobFight` HP gate |
| Feuerunke | Hundred Fists | Multiple uses; Whip Tongue (stun) immediately after; extreme melee resistance that ends during it; magic defence bonus only during it | `onMobFight` gate, `whip_tongue.lua` |
| Farruca Fly | Perfect Dodge | About every 20% HP, repeatable; attacks gain additional effect Paralyze while active | `onMobFight` |
| Dawon | Perfect Dodge | Repeated; Claw Cyclone spammed during it, full hate reset on hit; Defense Down aura; immune to physical while readying | `onMobFight`, `claw_cyclone.lua` |
| Jyeshtha | Mighty Strikes | Frequent; TP move immediately after; instant Break cast during it; casts Break only | `onMobFight`, spell list |
| Tammuz | Mighty Strikes | Permanent, 100% of the time | `onMobSpawn` addStatusEffect |
| Orcus | gravitic_horn | After use: aura of Gravity + Defense Down; HP bar revealed; resets enmity | `gravitic_horn.lua` (list 9002 already custom) |
| Orcus | quake_blast | Earth AoE that removes all equipment | `quake_blast.lua` |
| Skuld | Chainspell | About every 25% HP; only -ga spells while above 50%, any spell of its element below 50%; hate reset per cast | `onMobFight`, spell gating |
| Skuld/Urd/Verthandi | Breeze moves | Elemental state changes after each Breeze; Verthandi's TP set follows the season (Summer: Turmoil, Lethe; Autumn: Torrent, Zephyr; Winter: Norn, Torrent; Spring: Lethe, Zephyr) | per-NM script plus own list |
| Shoggoth | Chainspell | Only Sleepga II and single-target spells while active | `onMobFight`, spell gating |
| Erebus | Blood Weapon | Used several times; element follows the last damaging hit; self-heals with Tier IV below 90% | `onMobFight`, `onMagicHit` |
| Lord Ruthven | all TP | Hits everyone in AoE range regardless of hate; despawns 2 h after pop or on wipe | partly in `voidwalker.lua` (2 h despawn done) |
| Yilbegan | stances | Wings up/down changes physical/magical resistance; Aura selects the dark or light spell set | stance logic in the NM script |
| Blobdingnag | cytokinesis | Calls 6 septic minions; Dissolve is a conal Digest | list 9001 exists; minion summon not checked |

## Good as-is (wiki matches DB)

Orcus skills (3 of 3), Erebus (hell_slash, horror_cloud, black_cloud, blood_saber), Feuerunke (whip_tongue, abyss_blast, undead_mold plus stock Doomed moves), Jyeshtha (stock Scorpion list), Blobdingnag (custom list 9001).

## Not wiki-listed but on the DB list

Shoggoth: death_ray, catharsis. Chesma: chaotic_eye. Tammuz: great_bleat. Feuerunke: acid_breath, stinking_gas, call_of_the_grave. These come from the stock family lists and the wiki just doesn't mention them; keep unless a capture shows otherwise.

## Suggested order

1. Yilbegan: 12 missing Lua files (blocks the whole NM).
2. Lord Ruthven: Dirty Breath, Minax Glare rows and Lua; Decollation and Eternal Damnation Lua; drop Nocturnal Servitude.
3. Add the `VWK_NM` flag and helper, then the Capricornus, Krabkatoa and Lamprey Lord gates.
4. Own lists (9003+) for Verthandi (Norn Arrows), Krabkatoa, Shoggoth, Chesma, Dawon, Farruca Fly, Lamprey Lord.
5. HP-gated JAs (Mighty Strikes, Hundred Fists, Perfect Dodge, Chainspell, Blood Weapon) in each NM script's `onMobFight`.

Rules that apply: skill ids come from the DB rows above (never invent), damage numbers not on a wiki stay marked as design guesses, and run `tools/check_sql_id_collisions.py` before importing any new list.
