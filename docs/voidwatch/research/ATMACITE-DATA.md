# Atmacite data table (all 40) -- 2026-10-09

Source: BG Wiki Category:Atmacite dump (`wiki_raw/Category_Atmacite.wiki`) [W], parsed by script; DSP ids from `scripts/globals/keyitems.lua` (name match, all 40 resolved). FFXIclopedia Category:Atmacite read same day [W2]. Costs shown are post-"Rhapsody in Mauve" (1/20); multiply by 20 for pre-quest values.

Tags: [C] capture, [W] BG wiki, [W2] FFXIclopedia, [D] DSP keyitems.lua, [U] unknown.

## Level storage / slot

- list index = client KI id - 1806 (0..39) = DSP KI id - 1806 if the DSP and client ids agree [C for 1807/1810/1835/1841; remaining 36 assumed, **verify against client KI names before use**].
- option slot = KI id - 1805. Level = one 4-bit nibble; word = index // 8 (p0..p4), nibble = index % 8 (nibble 0 = low bits) [C].
- Level cap 15 (a nibble holds 0-15; 1 = fresh).

## Cost classes (cruor to reach level N, cumulative totals at L5/L10/L15, post-Rhapsody)

| Class | L5 | L10 | L15 | Members |
|---|---|---|---|---|
| A | 5,000 | 17,500 | 37,500 | Devotion, Persistence, Onslaught, Incursion, Destruction, Temperance |
| B | 7,500 | 26,000 (wiki typo "10,400") | 50,500 | Eminence, Enticement, Discipline, Mysticism, Rapidity, Preparedness |
| C | 7,500 | 33,750 | 78,750 | Coercion, Finesse, Latitude, Deluges, Unity, Exhortation, Skyblaze, the Slayer, the Adamant, Dark Designs, the Forager, Glaciers, Affinity, the Assassin, Aplomb, the Tropics, Curses |
| D | 12,500 | 56,250 | 131,250 | the Valiant, the Shrewd, the Vanguard, Assailment, Cataphract, the Parapet, Imperium, the Solipsist, the Depths, Preservation |
| E | 15,000 | 62,500 (wiki typo "12,500") | 140,000 | Provenance |

Per-level steps verified against captures [C]:
- Class C (Assassin 1841): step n = 750*(n-1), L2..L15. Sums to 7,500 / 33,750 / 78,750 exactly.
- Class A (Incursion 1810, Persistence 1807 tail): L2 500, L3 1000, L4 1500, L5 2000, L6-L10 2500 each, L11 3000, L12 3500, L13 4000, L14 4500, L15 5000. Sums to 5,000 / 17,500 / 37,500 exactly.
- Provenance 1835 (own class): captured L7 7500, L8 10000, L9 10000, L10 12500, L11 12500, L12 15000, L13 15000, L14 17500, L15 17500. Totals imply L2-L5 = 15,000 and L6 = 7,500 (L2-L5 split unknown [U]). Wiki L10 total "12,500" is a typo for 62,500 (consistent with captures).
- Classes B, D, E: only the L5/L10/L15 totals are known; the shape between is NOT captured [U]. Do not invent; either capture one of each or derive a stepped series that matches all three totals and tag it inferred.
- Wiki typo: class B L10 shows "10,400" but 520,000/20 = 26,000.

## Conflicts between sources

- [W] BG puts Coercion, Finesse, Latitude, Deluges, Unity at class C (150k/675k/1,575k). [W2] FFXIclopedia puts them at 225k/585k/1,245k (call it class X). Captured class C = Assassin only, so neither is decided for these. Default to BG until a capture.
- Name 1823: DSP/BG call it Exhortation (Qilin). [W2] says that atmacite is really "Promises" and Celaeno's 1811 is "Enticement (formerly Exhortation)". Needs client-name check before display text is written.
- [W2] Kaggen/Akvan/Pil periapt of emergence #2; Provenance Watcher #3; officer sells #1 for 50,000 cruor.
- [W2] says drop is guaranteed at 100% white; [W] says chance = white %. Unresolved.
- Obtained-from for 1832 Parapet is shown as Seductive Radiance, 1834 Solipsist as Maddening Radiance (same NM as 1833 Imperium) on BG; looks copy-pasted, verify before relying.

## Infuse rules [W2]

- Infuse cost: static 100 cruor per atmacite regardless of level [W2; level-1 case also C].
- Slots: one per periapt of emergence, max 3; effects stack. Switching only at a refiner or Planar Rift. Infused atmacite persists for all VW fights until switched.
- Purge option id: NOT captured [U].

## Table

| idx | slot | DSP KI | Name | Class | Obtained from | L1 | L5 | L10 | L15 |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 1 | 1806 | Devotion | A | Belphoebe | MND+1 Enmity-1 | MND+5 Enmity-5 Sphere: "Refresh"+1 | MND+10 Enmity-10 Sphere: "Refresh"+1 | MND+15 Enmity-15 Sphere: "Refresh"+2 |
| 1 | 2 | 1807 | Persistence | A | Kholomodumo | STR+1 Accuracy+1 Physical damage taken -1% | STR+5 Accuracy+2 Physical damage taken -2% | STR+10 Accuracy+4 Physical damage taken -4% | STR+15 Accuracy+5 Physical damage taken -5% |
| 2 | 3 | 1808 | Eminence | B | Hahava | HP+1% STR+1 INT+1 | HP+2% STR+2 INT+5 "Double Attack"+1% | HP+4% STR+4 INT+10 "Double Attack"+2% | HP+5% STR+5 INT+15 "Double Attack"+3% |
| 3 | 4 | 1809 | Onslaught | A | Murk-veined Baneberry | DEX+1 AGI+1 Spell interruption rate down 2% | DEX+2 AGI+5 Spell interruption rate down 10% | DEX+4 AGI+10 Spell interruption rate down 20% | DEX+5 AGI+15 Spell interruption rate down 30% |
| 4 | 5 | 1810 | Incursion | A | Melancholic Moira | DEX+1 Attack+1 Ranged Attack+1 | DEX+5 Attack+5 Ranged Attack+5 | DEX+10 Attack+10 Ranged Attack+10 | DEX+15 Attack+15 Ranged Attack+15 |
| 5 | 6 | 1811 | Enticement | B | Celaeno | MP+1% CHR+1 Magic Accuracy+1 | MP+3% CHR+5 Magic Accuracy+2 Sphere "Regen"+1 | MP+5% CHR+10 Magic Accuracy+4 Sphere "Regen"+2 | MP+10% CHR+15 Magic Accuracy+5 Sphere "Regen"+3 |
| 6 | 7 | 1812 | Destruction | A | Lord Asag | MP+5 "Magic Atk. Bonus"+1 Enhances "Fast Cast" effect +1 | MP+25 "Magic Atk. Bonus"+5 Enhances "Fast Cast" effect +1 | MP+50 "Magic Atk. Bonus"+10 Enhances "Fast Cast" effect +2 | MP+100 "Magic Atk. Bonus"+15 Enhances "Fast Cast" effect +3 |
| 7 | 8 | 1813 | Temperance | A | Akupara | DEF:+2 HP+5 DEX+1 | DEF:+10 HP+25 DEX+2 | DEF:+20 HP+50 DEX+4 | DEF:+30 HP+100 DEX+5 |
| 8 | 9 | 1814 | Discipline | B | Voidwrought | HP+1% "Magic Def. Bonus"+1 "Save TP"+20 | HP+3% All attributes +1 "Magic Def. Bonus"+3 "Save TP"+100 | HP+5% All attributes +1 "Magic Def. Bonus"+5 "Save TP"+200 | HP+10% All attributes +3 "Magic Def. Bonus"+10 "Save TP"+200 |
| 9 | 10 | 1815 | Coercion | C | Kaggen | STR+1 AGI+1 Accuracy+1 | STR+2 AGI+2 Accuracy+3 "Regain"+10 | STR+4 AGI+4 Accuracy+5 "Regain"+20 | STR+5 AGI+5 Accuracy+10 "Regain"+30 |
| 10 | 11 | 1816 | Finesse | C | Akvan | INT+1 Ranged Attack+1 Ranged Accuracy+1 Magic burst damage+2 | INT+3 Ranged Attack+2 Ranged Accuracy+5 Magic burst damage+10 | INT+5 Ranged Attack+4 Ranged Accuracy+10 Magic burst damage+20 | INT+10 Ranged Attack+5 Ranged Accuracy+15 Magic burst damage+30 |
| 11 | 12 | 1817 | Latitude | C | Pil | MND+1 "Subtle Blow"+1 TP Bonus +50 Haste +1% | MND+2 "Subtle Blow"+3 TP Bonus +250 Haste +1% | MND+4 "Subtle Blow"+5 TP Bonus +500 Haste +2% | MND+5 "Subtle Blow"+10 TP Bonus +500 Haste +3% |
| 12 | 13 | 1818 | Mysticism | B | Cath Palug | MP+1% AGI+1 "Magic Atk. Bonus"+1 | MP+2% AGI+2 "Magic Atk. Bonus"+3 | MP+4% AGI+4 "Magic Atk. Bonus"+5 | MP+5% AGI+5 "Magic Atk. Bonus"+10 |
| 13 | 14 | 1819 | Rapidity | B | Modron | MND+1 Enhances "Fast Cast" effect +1 "Snapshot"+1 | MND+5 Enhances "Fast Cast" effect +2 "Snapshot"+2 | MND+10 Enhances "Fast Cast" effect +4 "Snapshot"+4 | MND+15 Enhances "Fast Cast" effect +5 "Snapshot"+5 |
| 14 | 15 | 1820 | Preparedness | B | Mimic King | VIT+1 INT+1 Magic damage taken -1% | VIT+3 INT+2 Magic damage taken -2% | VIT+5 INT+4 Magic damage taken -4% | VIT+10 INT+5 Magic damage taken -5% |
| 15 | 16 | 1821 | Deluges | C | Uptala | Enmity+1 VIT+1 "Store TP"+1 | Enmity+5 VIT+5 "Store TP"+5 "Double Attack"+1% | Enmity+10 VIT+10 "Store TP"+10 "Double Attack"+2% | Enmity+15 VIT+15 "Store TP"+15 "Double Attack"+3% |
| 16 | 17 | 1822 | Unity | C | Aello | MND+1 Ranged Accuracy+1 "Waltz" potency +2% Song casting time -1% | MND+2 Ranged Accuracy+3 "Waltz" potency +10% Song casting time -2% | MND+4 Ranged Accuracy+5 "Waltz" potency +20% Song casting time -4% | MND+5 Ranged Accuracy+10 "Waltz" potency +30% Song casting time -5% |
| 17 | 18 | 1823 | Exhortation | C | Qilin | HP+1% VIT+1 Skillchain damage +2% | HP+2% VIT+2 Skillchain damage +10% | HP+4% VIT+4 Skillchain damage +20% Sphere: "Regain"+10 | HP+5% VIT+5 Skillchain damage +30% Sphere: "Regain"+20 |
| 18 | 19 | 1824 | Skyblaze | C | Ocythoe | DEX+1 Accuracy+1 Lightning elemental attack+1 Thunder+5 | DEX+3 Accuracy+5 Lightning elemental attack+5 Thunder+25 | DEX+5 Accuracy+10 Lightning elemental attack+10 Thunder+50 | DEX+10 Accuracy+15 Lightning elemental attack+15 Thunder+100 |
| 19 | 20 | 1825 | the Slayer | C | Gaunab | STR+1 AGI+1 Fire elemental attack+1 Fire+5 | STR+3 AGI+3 Fire elemental attack+5 Fire+25 | STR+5 AGI+5 Fire elemental attack+10 Fire+50 | STR+10 AGI+10 Fire elemental attack+15 Fire+100 |
| 20 | 21 | 1826 | the Adamant | C | Kalasutrax | HP+5 Breath damage taken -1% Earth+5 Water+5 | HP+25 Breath damage taken -2% Earth+25 Water+25 | HP+50 Breath damage taken -4% Earth+50 Water+50 | HP+100 Breath damage taken -5% Earth+100 Water+100 |
| 21 | 22 | 1827 | the Valiant | D | Ig-Alima | HP+1% All attributes +1 Accuracy+1 Haste+1% | HP+3% All attributes +5 Accuracy+2 Haste+2% | HP+5% All attributes +10 Accuracy+4 Haste+4% | HP+10% All attributes +15 Accuracy+5 Haste+5% |
| 22 | 23 | 1828 | the Shrewd | D | Botulus Rex | Damage taken -1% "Magic Atk. Bonus"+1 Magic Accuracy+1 Enmity-1 | Damage taken -3% "Magic Atk. Bonus"+3 Magic Accuracy+5 Enmity-3 | Damage taken -5% "Magic Atk. Bonus"+5 Magic Accuracy+10 Enmity-5 | Damage taken -10% "Magic Atk. Bonus"+10 Magic Accuracy+15 Enmity-10 |
| 23 | 24 | 1829 | the Vanguard | D | Beguiling Radiance | Attack-5 "Subtle Blow"+1 Haste+1% "Double Attack"+1% | Attack-25 "Subtle Blow"+5 Haste+3% "Double Attack"+2% | Attack-50 "Subtle Blow"+10 Haste+5% "Double Attack"+4% | Attack-100 "Subtle Blow"+20 Haste+10% "Double Attack"+5% |
| 24 | 25 | 1830 | Assailment | D | Beguiling Radiance | STR+1 "Magic Attack Bonus"+1 "Slow"+1% Addle+1% | STR+5 "Magic Attack Bonus"+5 "Slow"+5% Addle+5% | STR+10 "Magic Attack Bonus"+10 "Slow"+10% Addle+10% | STR+20 "Magic Attack Bonus"+20 "Slow"+15% Addle+15% |
| 25 | 26 | 1831 | Cataphract | D | Seductive Radiance | HP+1% MND+1 "Magic Defense Bonus"+1 "Cure" potency +1% | HP+2% MND+2 "Magic Defense Bonus"+3 "Cure" potency +5% | HP+4% MND+4 "Magic Defense Bonus"+5 "Cure" potency +10% | HP+5% MND+5 "Magic Defense Bonus"+10 "Cure" potency +15% |
| 26 | 27 | 1832 | the Parapet | D | Seductive Radiance | DEF+5 STR+1 VIT+1 Damage taken -1% | DEF+25 STR+1 VIT+1 Damage taken -1% | DEF+50 STR+3 VIT+3 Damage taken -2% | DEF+100 STR+5 VIT+5 Damage taken -3% |
| 27 | 28 | 1833 | Imperium | D | Maddening Radiance | All attributes +1 Enmity-2 Enhances "Resist Charm" effect +1 Enhances "Resist Amnesia" effect +1 | All attributes +2 Enmity-10 Enhances "Resist Charm" effect +5 Enhances "Resist Amnesia" effect +5 | All attributes +4 Enmity-20 Enhances "Resist Charm" effect +10 Enhances "Resist Amnesia" effect +10 | All attributes +8 Enmity-30 Enhances "Resist Charm" effect +25 Enhances "Resist Amnesia" effect +25 |
| 28 | 29 | 1834 | the Solipsist | D | Maddening Radiance | All attributes +1 Enmity+2 Enhances "Resist Charm" effect +1 Enhances "Resist Amnesia" effect +1 | All attributes +2 Enmity+10 Enhances "Resist Charm" effect +5 Enhances "Resist Amnesia" effect +5 | All attributes +4 Enmity+20 Enhances "Resist Charm" effect +10 Enhances "Resist Amnesia" effect +10 | All attributes +5 Enmity+30 Enhances "Resist Charm" effect +25 Enhances "Resist Amnesia" effect +25 |
| 29 | 30 | 1835 | Provenance | E | Provenance Watcher | Damage taken -1% | Damage taken -3% | Damage taken -5% Occasionally negates MP cost Auto-Reraise | Damage taken -10% Occasionally negates MP cost Auto-Reraise Sphere: Reraise |
| 30 | 31 | 1836 | Dark Designs | C | Abununnu | INT+5 Magic Accuracy+5 TP Bonus +50 | INT+6 Magic Accuracy+6 TP Bonus +250 | INT+8 Magic Accuracy+8 TP Bonus +500 | INT+10 Magic Accuracy+10 TP Bonus +500 |
| 31 | 32 | 1837 | the Forager | C | Tsui-Goab | DEX+5 VIT+5 | DEX+6 VIT+6 | DEX+8 VIT+8 "Regain"+10 | DEX+10 VIT+10 "Regain"+10 |
| 32 | 33 | 1838 | Glaciers | C | Isarukitsck | DEF+10 "Magic Defense Bonus"+5 "Ice Attack Bonus"+1 | DEF+12 "Magic Defense Bonus"+6 "Ice Attack Bonus"+5 | DEF+16 "Magic Defense Bonus"+8 "Ice Attack Bonus"+10 | DEF+20 "Magic Defense Bonus"+10 "Ice Attack Bonus"+15 |
| 33 | 34 | 1839 | Affinity | C | Fjalar | Enhances "Fast Cast" effect +1 Depending on day: Enhances elemental magic +5 Depending on day: Magic Accuracy+10 | Enhances "Fast Cast" effect +3 Depending on day: Enhances elemental magic +6 Depending on day: Magic Accuracy+12 | Enhances "Fast Cast" effect +5 Depending on day: Enhances elemental magic +8 Depending on day: Magic Accuracy+16 | Enhances "Fast Cast" effect +8 Depending on day: Enhances elemental magic +10 Depending on day: Magic Accuracy+20 |
| 34 | 35 | 1840 | the Depths | D | Bismarck | HP+10% STR+10 "Water Attack Bonus"+1 | HP+11% STR+11 "Water Attack Bonus"+5 | HP+13% STR+13 "Water Attack Bonus"+10 Sphere: "Double Attack"+1% | HP+15% STR+15 "Water Attack Bonus"+15 Sphere: "Double Attack"+2% |
| 35 | 36 | 1841 | the Assassin | C | Dimgruzub | HP+100 AGI+5 "Double Attack"+1% | HP+120 AGI+6 "Double Attack"+1% | HP+150 AGI+8 "Double Attack"+2% | HP+200 AGI+10 "Double Attack"+3% |
| 36 | 37 | 1842 | Aplomb | C | Vanasarvik | MP+100 MND+5 Enhances "Resist Silence" effect +1 | MP+120 MND+6 Enhances "Resist Silence" effect +5 | MP+150 MND+8 Enhances "Resist Silence" effect +10 | MP+200 MND+10 Enhances "Resist Silence" effect +25 |
| 37 | 38 | 1843 | the Tropics | C | Yalungur | "Subtle Blow"+5 CHR+5 "Triple Attack"+1% | "Subtle Blow"+6 CHR+6 "Triple Attack"+1% | "Subtle Blow"+8 CHR+8 "Triple Attack"+2% | "Subtle Blow"+10 CHR+10 "Triple Attack"+3% |
| 38 | 39 | 1844 | Curses | C | Brekekekex | INT+5 "Magic Attack Bonus"+5 Magic Accuracy+1 | INT+6 "Magic Attack Bonus"+6 Magic Accuracy+2 | INT+8 "Magic Attack Bonus"+8 Magic Accuracy+4 | INT+10 "Magic Attack Bonus"+10 Magic Accuracy+5 |
| 39 | 40 | 1845 | Preservation | D | Morta | MP+10% Enhances "Refresh" effect +3 "Earth Attack Bonus"+1 | MP+11% Enhances "Refresh" effect +4 "Earth Attack Bonus"+5 | MP+13% Enhances "Refresh" effect +4 "Earth Attack Bonus"+10 Sphere: "Magic Attack Bonus"+1 | MP+15% Enhances "Refresh" effect +5 "Earth Attack Bonus"+15 Sphere: "Magic Attack Bonus"+2 |
