# Siknoz captures: weakness / stagger findings (2026-10-06)

Source: `Playthrough Captures/voidwatch_captures/manual_extracted` + `extracted` caplog text (toolkit captures 734-752, Siknawz layout). Tags: [C] = seen in retail capture.

## Weakness feedback [C]
Zone message when a weakness is hit, one line per qualifying action:
`The fiend appears <degree> vulnerable to <X>!`
- Degrees: (none) 1115, "highly" 318, "extremely" 130. Degree scales with how many/ which weaknesses stack (not yet derived).
- `<X>` categories seen (counts): weapon-skill type 540 (e.g. "great sword weapon skills"), "<element> elemental black magic" 416, blue magic 207, white magic 114, blood pacts 82, ninjutsu 75, bard songs 54, pet special attacks 15, job abilities 33 ("dragoon abilities" 13, monk 9, warrior/dancer 6, thief 5, ...), automaton special attacks 1.
- Elements: fire/ice/wind/earth/lightning/water/light/darkness.
- Each NM has several active weaknesses that rotate; the capture shows the message fires per hit even for different categories in the same fight (Kaggen 2024-09-19: water BLM, ice BLM, fire BLU, earth BLM in the first 30 s).
- DSP implication: need a weakness hook for JA / pet / avatar / automaton in addition to WS + spells (already flagged as a gap in DESIGN-INPUTS-ABYSSEA-SPAWN.md). Message ids per zone still unresolved.

## Stagger / blitz [C]
- Sequence: weakness hits -> "Synchronic blitz commences" -> "Synchronic blitz complete." -> "Alignment increases by N% across the spectrum!" -> "Blue: a% / Red: b% Yellow: c% / Green: d% White: e%".
- Example Kaggen 19:42:38: +88%; resulting Blue 350 / Red 350 / Yellow 225 / Green 225 / White 100 (caps).
- Five alignment colours (blue, red, yellow, green, white) exist; cobalt/rubicund cells move blue/red. Yellow/green likely xanthous etc. (unverified).
- No explicit "weakness triggers stagger" message found. One stray "(Siknawz) additive stagger duration looks like" line is an addon/debug note, not a game message.

## Other fight facts from Kaggen capture
- Start: Rift event 6001, option 1; zone msg 11540; "You have 30 minutes".
- Treasure Hunter AE works on the NM (TH 9/10 shown).
- NM TP moves seen: Macerating Bile, Paralyga (spell), Preying Posture (Attack Boost).

## Still open
- Exact weakness-count -> degree and -> blitz trigger rule.
- Message ids per zone for the above (step 3).
- Rift p1/p2, Pyxis p1 meanings.

## Rift / Pyxis param pass (step 3, 2026-10-06) [C]
Rift 0x034 `[p1,p2,0,0,0,0,p7,p8]` across ~40 events:
- p1 is 6 or 14 only (also 2126 on a separate-era capture); p2 is 0, 16 or 18. Looks like bitfields: 6=0b0110, 14=0b1110; 16=0b10000, 18=0b10010.
  Pattern: p1=6 with indigo I-III (370-372) / crimson I-II; p1=14 with crimson I/IV, indigo IV, jade/white (374-377). Likely "which options/ascent slots the menu offers"; NOT confirmed.
- p7 = player's cruor total (drops 5000 per tier-I NM: 18685->13685), p8 = abyssite KI id. Confirmed.
Pyxis 0x034 `[p1,p2,0...]`: p1/p2 values like 749, 695, 798, 866, 3508, 3510, 4118 look like **item ids** (reward items offered, e.g. 749 = a common reward), not a bitfield. Unverified; check against item DB before wiring.

### Pyxis p1/p2 verified against DSP item_basic [V]
All 14 distinct values resolve to real items: 749 mythril beastcoin, 695 willow log, 798 turquoise, 866 wyvern scales, 3508 crystal petrifact, 3510 silver mirror, 4118 hi-potion +2, 644 mythril ore, 690 elm log, 694 chestnut log, 815 sphene, 895 ram horn, 645 darksteel ore, 700 mahogany log. => Pyxis event params = reward item ids (p1,p2 = first items shown; several events carry only p1). Likely drop-list display; full per-player pool selection still not visible in params.

## Stagger -> blitz sequence timeline (Kaggen 2024-09-19, 19:41-19:44) [C]
1. Weakness lines (10897-10903 family) print on each qualifying hit (mixed categories; several concurrent weaknesses: wind BLM, water BLU "highly", lightning blood pact, fire BLM, water ninjutsu "extremely", monk abilities).
2. A hit prints **"<player>'s attack devastates the fiend!"** (10890) and in the same second **"Synchronic blitz commences!"** (10906) -> devastate = the blitz trigger (first at 19:41:37, ~20 s into the fight).
3. During the blitz: "Alignment level increases!" (Red 320% (+220%), Yellow/Green 170% (+70%), White 70% (+70%)); further devastates keep adding; "Your alignment has reached maximum level across the spectrum" (10904) -> "Red alignment reaches maximum! Red: 350%", "Yellow and green alignments reach maximum! 225%".
4. "Synchronic blitz complete." (10907) -> "Alignment increases by N% across the spectrum!" (10908, e.g. 88%, later 10%) + summary (Blue 350/Red 350/Yellow 225/Green 225/White 100). Caps: blue/red 350%, yellow/green 225%, white 100%.
5. A second blitz started 19:42:41 on the next devastate and ended 19:42:48 (~7 s); i.e. blitz can retrigger repeatedly; duration varies.
6. On kill: "Final Spectral Alignment Blue 550% (+150%) Red 550% (+150%) Yellow 237% (+0%) Green 237% White 100%" - final includes ascent-item bonuses (+150% blue/red) beyond the 350% in-fight cap.
- Open: exact rule for which hit "devastates" (likely a weakness hit when stagger meter fills); which colour each hit type raises (blue/red appear tied to weapon-skill vs magic by wiki, not yet derived from logs).

## Devastate/blitz trigger statistics (72 "devastates" events, all captures) [C]
- 67 are "Siknawz's attack devastates" and 5 are "Raguza's": only the local capturing player's own hit ever prints it (not other party members), so it is a per-player message.
- Only 5/72 have a weakness message in the preceding 4 lines; 9/72 follow a Magic Burst and 1 a skillchain. So devastate is NOT simply "a weakness hit" and NOT mainly a burst/skillchain: the trigger is hidden state (probably a per-NM stagger meter filled by accumulated weakness hits, then the next hit devastates).
- Rule for DSP MVP (design choice, not retail-proven): accumulate weakness hits -> at threshold, next hit by that player triggers blitz. Real thresholds/colours still need the actionview (0x028/0x029 message ids) pass.

## Blitz threshold test (weakness msgs between blitz starts) [C]
Weakness messages (the capturer's own hits) between consecutive blitz starts across 55 blitzes: min 0, median 9, max 43 (0 x7, 1-5 x ~12, 6-10 x ~13, 11+ x ~22). No fixed count -> trigger is not "N weakness hits". Probably time/damage/HP-gated or server-side hidden meter. **Decision:** treat the blitz trigger as unresolved retail behavior; MVP uses a simplified configurable rule (flagged "invented, tuned to captured median ~9 weakness hits / ~20 s first blitz"), documented as such.
