# Voidwatch lights / weakness triggers: in-game test plan (all [D], untested)

Weakness set per fight (rolled in `vwWeaknessInit`): one elemental-magic element (`VW_WEAK_ELEM`), one weapon type
(`VW_WEAK_WS`), one job ability (`VW_WEAK_JA`), one avatar "<Element> IV" (`VW_WEAK_AVATAR`). Every hit: +20 blue/red,
+10 yellow/green, +25 white (blitz doubles all but white). Every 3rd hit starts a 15 s blitz.

Not covered: jug pets, automaton, ninjutsu/songs/blue magic (elemental-magic skill 36 only), Light/Dark avatar pacts,
Relic/Mythic/Empyrean/Aeonic WS exclusion, miss/resist check, weakness replacement after a hit, /fume, extreme tier.

## Steps
1. Spawn any VW NM (e.g. Ig-Alima). GM: `!getlocalvar`-style check not available, so read the weakness via a temporary
   `printf` or just test each category.
2. Hit with: elemental nuke of each element (one should count); a WS of each weapon type; each of the 20 JAs; each of
   the six avatar IV pacts. Watch lights via the alignment messages at blitz end.
3. After 4 counted hits white should read 100. Kill the NM and confirm the white-gated key item/atmacite can drop.
4. Confirm non-VW mobs are unaffected (JA scripts and `*_iv.lua` call helpers that no-op without `VW_NO_REBUFF`).
5. Check map-server log for Lua errors from `onWeaponskillHit` (must return 0) and the edited ability scripts.

## Weakness messages (added)
Ids are `msgWeakElem` + offset (same block layout as Ru'Aun 10897-10901; the +7 blitz offset matches in every zone cfg):
magic = +0 (element, degree), weapon skill = -2 (type, kind 0, degree), job ability = -1 (job, degree), avatar pact = +2 (element,
kind 0, degree). Degree is always 0 (no "highly/extremely" tiers yet). Element is translated DSP ELE_* -> client index
(fire1 ice2 wind3 earth4 lightning5 water6 light7 dark8); the old code sent the DSP index, which was wrong for 5 of 6 elements.
Check in game: each hit prints "The fiend appears vulnerable to <X>!" with the right weapon/job/element name.

## Tiers (added) [D]
One category extreme (degree 2), one high (degree 1), two normal, per fight. Per hit blue/red 20 / 100 / 250 (yellow/green half;
blitz doubles), white +0 / +25 / +100 (so normal hits no longer give white; ~4 high hits or 1 extreme = 100%). Extreme is one-shot;
a high weakness moves to a random normal category once hit. The degree param of each client line is the tier, so check for
"highly"/"extremely" in the weakness text. 1-tier rates are wiki figures but the 4-slot split and the half-rate for yellow/green are judgement.

## Periapt hints (added) [D]
Holding Periapt of Guidance (KI 1777) / Percipience (1778): a non-matching weapon skill / job ability (guidance) or elemental spell
(percipience) has a 15% chance (guess, rate unknown) to print the weakness line for that category without raising lights.
Not built: purchase of periapts (bg-wiki: Voidwatch Officer, guidance/percipience 150,000 cruor, emergence 50,000; no capture of that
menu so no csid/option), Clarity, Sapience, ability hints for JAs outside the 20 hooked scripts.
