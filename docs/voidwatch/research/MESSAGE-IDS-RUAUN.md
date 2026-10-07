# Voidwatch zone message ids — Ru'Aun Gardens (zone 130) [V]
Source: fresh `mission_toolkit.py "Ru'Aun_Gardens"` pull 2026-10-06 -> `research/zone_pulls/RuAun_Gardens/dialog.yml` (events dat 5950, dialog dat 6550). Dat ids: events ROM2/13/13, dialog ROM2/17/63.
Block is contiguous and ordered; base is zone-specific (Qufim capture: "materializes" = 11540, here 10799), so offsets are reusable, absolute ids are NOT — re-pull per zone.

| id | text (abridged) |
|---|---|
| 10780 | gains clearance ... voidstone NOT expended (spoils limited) |
| 10781 | gains clearance ... unused voidstone carried over |
| 10782 | ventured too far; will lose Voidwatcher status |
| 10783 | Voidwatcher status revoked |
| 10784 | returned to the field of battle |
| 10785 | You have N minutes to complete the battle |
| 10786 | N minutes remaining |
| 10787 | only N seconds remaining |
| 10788 | time is up |
| 10789 | monster fades before your eyes |
| 10790/10791 | temporary item available / all recharged |
| 10792 | "mysterious energy seeping forth..." (Rift click, no initiate) |
| 10793 | abyssite resonates with voidstone; may commence |
| 10794 | could be initiated if you had X and Y |
| 10795 | presence does not elicit a reaction |
| 10796 | Rift menu: Nothing / Initiate / View alignment / Examine atmacite / Read up |
| 10797 | Use voidstone? Yes/No |
| 10798 | lack the abyssite |
| 10799 | A fiend materializes from the planar rift! |
| 10800 | Alignment: Blue = reward quantity, Red = reward quality |
| 10801 | Yellow = experience yield, Green = cruor yield |
| 10802 | ascent-item bonuses added to final value |
| 10803-10862+ | atmacite infuse/enrich/purge menus, cruor costs, lore text |

## Findings
- **Alignment colours decoded:** blue=quantity, red=quality, yellow=exp, green=cruor (white likely = base/unused; unverified). Explains the 5-colour readout in captures.
- Rift menu (10796) matches capture option 1 = initiate.
- Weakness line ("The fiend appears vulnerable to ...") is NOT in the zone dialog dat -> generic system message table (not zone-local); locate separately (Qufim captures show it zone-independent).

## Event decode (explore_event.py, Ru'Aun) [V]
- Entities: Planar Rift 17310111-13 -> csid 6000-6002; Riftworn Pyxis 17310114-16 -> csid 6003-6005 (matches captures; csid = 6000 + index, Pyxis = +3).
- **Pyxis event (6003)** copies params[0..7] into 8 scratch slots = **up to 8 reward-item slots (0 = empty)**; UI strings 10880 "Obtain this item?" and 10915 "Obtain the <item>? Yes / No / Obtain all". Confirms capture finding that Pyxis params are item ids; server must send all (up to 8) item ids in startEvent params.
- **Rift event (6000)** large (17907 B), uses msg 10792 (mysterious energy), 10794 (could be initiated if...), menu 10796; params[0..6]+ drive branching (p1/p2 bit flags still undecoded in code; needs full read of the branch tree).

## Rift csid 6000 param layout from client script [V] (explore_event.py, lines 99-113)
- params[0], [1], [2] copied raw; **params[3] = three packed 7-bit fields** (bits 0-6, 7-13, 14-20); **params[4] = three packed 4-bit fields** (bits 0-3, 4-7, 8-11); params[5], [6] raw (script reads 7; capture sends 8 — 8th = abyssite KI id per capture).
- Applied to the zach2good sample `2126, -2139615233, 24, 536872214, 170, 0, 2705151, 1450`: p3=0x20000516 -> fields (22, 10, 0); p4=170 -> (10, 10, 0). Plausibly the three infused-atmacite slots (levels/ids) — UNVERIFIED.
- The Siknoz captures send `14,16,0,0,0,0,cruor,KI` (p4/p5 zero) = no atmacite infused / older layout; p1/p2 are the first two raw params. Meaning of raw p1/p2 (2126 vs 14/6) still undecoded; may be a KI/atmacite bitmask.

## Fight/reward message block 10880-10914 [V] (Ru'Aun fresh pull; correction: weakness text IS zone-local, my earlier grep missed it because it is built from ${choice} parts)
| id | meaning | params |
|---|---|---|
| 10880 / 10914-ish | Pyxis "Obtain this item?" / "Which item will you obtain?" (8 item slots + Relinquish all / Obtain all) | item ids |
| 10885 | chest already disappeared | |
| 10886 / 10887 | Relinquish all? / "All reward items have been relinquished." | |
| 10888 | "Your attack staggers the fiend! Alignment level increases!" + Blue/Red/Yellow/Green/White % | 0=blue 1=red 2=yellow 3=white 4=green |
| 10889 | same, "Maximum alignment reached!" | same |
| 10890 | "<entity>'s attack devastates the fiend!" | entity |
| 10891/10892 | single-colour (Blue/Red) increase / max | p0 colour 0=blue 1=red, p1 delta, p2 new % |
| 10893/10894 | Yellow+Green increase / max | p1 delta, p2 value |
| 10895/10896 | White increase / max | |
| 10897 | weakness: weapon type (hand-to-hand..marksmanship/pet/automaton/avatar/wyvern) + weapon skills/special attacks/blood pacts | p0 type, p1 kind, p2 degree (0 none,1 highly,2 extremely) |
| 10898 | weakness: job abilities (20 jobs) | p0 job, p1 degree |
| 10899 | weakness: elemental magic (generic) | p0 element, p1 degree |
| 10900 | weakness: element + white/black/ninjutsu/bard/blue magic | p0 element, p1 degree, p2 school |
| 10901 | weakness: element + blood pacts / wyvern abilities | p0 element, p1 kind, p2 degree |
| 10902 / 10903 | weakness: pet special attacks / automaton special attacks | p2 degree |
| 10904 | max alignment across the spectrum, "perfectly aligned" | |
| 10905 | "The aura of your foe suddenly changes!" (weakness rotates) | |
| 10906 | "Synchronic blitz commences! Assail the fiend with all your strength!" | |
| 10907 | "Synchronic blitz complete." | |
| 10908 | "Alignment increases by N% across the spectrum!" | p0 |
| 10909 / 10910 | Blue/Red/Yellow/Green summary / White | |
| 10911 | "surge of extradimensional power... Spare the fiend no mercy!" (blitz buff start) | |
| 10912 | "Alignment surge extended! (N-chain)" | |
| 10913 | surge left your body | |

Mechanics implied (all [V] from client text, behaviour rules still [W]): each weakness hit staggers -> raises one colour (red/blue by weapon-skill-vs-magic? unverified), weakness rotates ("aura changes"), maxed alignment triggers the Synchronic Blitz (surge, chain extension), alignment colours scale reward/exp/cruor on kill. This is the full set of messages the server must emit; DSP Abyssea qm/weakness code (YELLOW/BLUE/RED_WEAKNESS in abyssea TextIDs) is the nearest precedent.
