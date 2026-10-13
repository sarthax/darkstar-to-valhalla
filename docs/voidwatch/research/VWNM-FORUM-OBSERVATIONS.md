# Voidwatch NM — Forum Observations (BlueGartr thread 104509)

Source: `research/bluegartr/voidwatch_thread.md` (full scrape, 2011-05 to 2012-08). Per-NM excerpts: `research/bluegartr/by_nm/<NM>.txt`.
Citations are post numbers, `#n`. These are **player reports from retail, not verified data**. Where reports conflict, both are listed.
Nothing here is an ID, position or number to paste into SQL/Lua without a check against DAT/capture sources (project rule).
HP figures are player estimates from parser damage and are rough.

Legend: **[firm]** reported by several people or confirmed against a log; **[single]** one report; **[theory]** speculation.

---

# Part A — Per-NM observations

## Tier 1

### Krabimanjaro (Jeuno path T1, our implemented slice)
- Past 50% HP it gains a defense boost and seems more evasive. Angon, COR rolls and DDs were used to get over it (#231). **[single]**
- Venom Shower is spammed, e.g. 3x within 45s (#229). Double Venom Shower at low HP, plus hate resets, slowed kills below 50% (#791). Regen, Cureskin and MDT gear help (#231).
- Easy to CS-stun (#1136). Drops reported: Percept Bow, cuffs (#298). Periapt of Intensity (#214).
- A weakness message that said only "special attacks" with no job (#313): an SE text bug.
- **Cross-check vs our build:** the thread supports defense and evasion rising past 50%. It does not mention regain at low HP.

### Sarimanok (East Ronfaure T1, Puk, THF-type)
- Very high evasion and a decent triple-attack rate that rises as HP falls (#4). **[single]**
- Before 50%: Wind Shear/Crosswind, Aeroga II, Aero IV. After 50%: Ill Wind (about 700-800 AoE), Somnial Durance (AoE sleep), then instant Aeroga III (about 1k through Shell V). The combo causes a **full hate reset**, and the NM kills the healer.
- Drops: chimera hairpin (#203). Shares an abyssite with Cottus (#45).

### Cottus (Gigas, Briarius model)
- Basically Briarius without atma. Easy above 50%. Below 50% it runs around spamming TP moves (Mercy Strike and similar). Smite 1500-4500 and Hi about 1000-1500 (#646).
- No hate reset, so it is easier than Sarimanok (#646). Drop: Roller's Ring (#289). Periapt of Readiness. Base xp and cruor 5000 (#6).
- Final lights on first kill: Blue 270, Red 390, Yellow 225, Green 225, White 75 (#6).

### Pancimanci (Mandragora)
- Dream Flower suppresses hate until the targets are awakened and act on it (#613). Casts -ga spells. Possible Hundred Fists (hate reset), Fatal Scream and Head Butt (#612, unconfirmed).
- Drops: Impatiens (3x on capped lights, #385), feet seals (#671).

### Ushumgal (Peiste, Kukulkan type)
- High evasion, spams AoE paralyze and petrify. Calcifying Mist about 1k, first used around 40% (#82). Pets unsummon at start.
- Fight length 15-20 min with a weak group. Add effect: slow. Drops: Accursed Belt, Periapt of Exploration (#150).
- Cell names: xanthous raises yellow, rubicund raises red, cobalt raises blue (#52).

### Ogbunabali (Vermin)
- Gravitic Horn: percent damage; Fanatic's does not block it (#2147). EA+Scherzo is only useful here and on a few moves (#818).
- Drops: Mantodea Harpe, Pipilaka Belt (#316). Periapt of Focus.

### Lorbulcrud
- Spams Silencega and Waterja plus an AoE TP. Gets huge -PDT at low HP (#104). Dissolve needs an off-tank (#1138). Drops: Veisa Collar, fulcrum pole. Periapt of Readiness (#104).

### Melancholic Moira
- Uses EBB (Evil Breath-type radial breath, AoE, may be NPC-targeted so it is not visible unless unfiltered), tainting breath, bad breath at about 600-800 (#106, #612). Breaths may all be radial (#611).
- Final lights: Blue 450, Red 500, Yellow 325, Green 225, White 75 (#176). Drops: Appetence Crown, silver mirror (#1357).

### Seymour (Sallow Seymour)
- Mud Stream spam kills pets and is rough for pet parties (#215).

### Holy Moly (Sabotender, Yuhtunga)
- Soothing Aroma (charm AoE) and a poison aura. Re-summons adds with charmga (#1010, #1085). Keep spare hate-holders ready for the charm. Needs a strong tank (#1092).
- Drops: Valseur's Ring, rafflesia vine (trash) (#996, #1095). Easiest Elshimo T1 for the KI (#1441).

### Neith (Diremite)
- Tarsal Slam drops the tank to 1 HP. 4-5 spider adds (Neith's Bobbins; probably 5), which WS in sync with her and respawn through TP moves (#1038, #1078, #1093).
- Drops: Calcitrant Stole, Prolix Ring (#996, #1038).

### Ildebrann (Zilart T1, wyrm)
- See the earlier summary below. Fight in the air until 25% (#2057).
- Spawns 2 pets at 100/75/50/25%. It flies while the pets are alive. Pets use Voidsong (full dispel). AoE Absolute Terror. Baleful Roar. Fire resist about 350.
- Drops: Gram (#996).

### Tangaroa (Kuftal Tunnel)
- Adds are weak, re-summoned several times. Killing adds boosts alignment gain from staggers briefly ("alignment blitz", chained: 2-chain etc.) (#982). Possibly a Doom aura that rarely kills (#989).
- Drops: Mollusca Mantle, Paguroidea Ring (#975).

### Aht Urhgan T1 (#2435, #2657)
- **Dimgruzub** (Arrapago Reef): Qutrub plus 2 "Assassin's Apprentice" adds. Adds cleave and stun (Ochain blocks). Drops Ghadhab Nails, Aluh Jambiya. Atmacite of the Assassin, Periapt of Catalysis.
- **Vanasarvik** (Mount Zhayolm): Imp plus 6 imps, resummoned with Bugle Call. Stifling Tantara (silence) and Grating Tantara (amnesia), both AoE about 500-600, both blocked by Fanatic's. Unique move Dark Recital (effects unknown, #2657). Atmacite of Aplomb.
- **Yalungur** (Mamook): Colibri that casts BRD songs; Tropic Tenor about 1k, strips buffs. Levels up when it eats food. Adds cast only Firaja or Thundaja. Drops Ereptor Lance.
- **Brekekekex** (Caedarva Mire): absorbs/dispels buffs. Strategy at #2504: BLM x2 + WAR, kill the adds first, Fanatic's then Fool's under 40%, 2hr zerg.

### Promathia T1 (#2562)
- **Abunnunu**: Gloam Servitor WAR (syncs TP with the main) and BLM (casts when the main casts). Accurst Spear (AoE + curse), Hellborn Yawp, Condemnation (stun). Hold the pets.
- **Tsui-Goab**: Bloodswiller Fly x 2. Exorender kills any fly it hits. If a fly dies, Tsui-Goab levels up. Keep flies far away.
- **Isarukitsck**: Little Wingman x 3. Whiteout (AoE zombie, sleep, damage). Yawn, Frigid Shuffle, Beak Lunge.

## Tier 2 and 3

### Belphoebe
- Fixed TP order of four Breeze moves, then Norn Arrows. Stunning repeats the same move. Casts Blizzaja, Thundaja, Death at low HP.

### Lord Asag
- Death and Firaja at low HP. Nosferatu's Kiss and charm below 50%. Wings of Gehanna hits for 600-700.

### Akupara
- Testudo Tremor from about 25-50%. Spams Breakga and Tortoise Song. Drops Deluxe Animator (#248).

### Murk-Veined Baneberry
- Ga3 spam at the start, Ga4 under 50%, Breakga and Death, Impact. Ritual Bond then teleports around, with Throat Stab (#611). EA+Scherzo is useful on Throat Stab (#818).

### Kholomodumo
- Accursed Armor (curse spikes), Amnesic Blast (cone amnesia + damage). Thunderbolt/Meteor and Ecliptic Meteor activate only below 50% (#614). Use Fanatic's or Fool's under 50%; with Fool's, Meteor does no damage (#798). Shell V with MDT survives Meteor (#801).
- Drops: Genesis Locket, Genesis Shield (#292).

### Gasha (Jeuno T2)
- Three forms: 10' Silence aura, then 10' Amnesia aura plus Crepuscle Blade, then 10' Paralyze aura (#1027).

### Nympha Eunomia / Roly-Poly
- Eunomia's second phase heals heavily when enfeebled; one case healed 18,000 HP. Avoid debuffs and dots (#1520, #1522).
- Roly-Poly takes bonus damage from magic (#1121).

### Mellonia (Gnat)
- Casts Aeroga/Waterga III-IV; random auras (silence, amnesia, bio). Needs two tanks and room (#1027, #1121, #1275).

## Tier 4+

### Hahava
- About 70k HP. Raksha/Yaksha stances, each -50% (Raksha is MDT, Yaksha is PDT), swapping about every 2 minutes.
- Raksha: Vengeance causes Weakness and muddle. Yaksha: Oblivion below 50%.
- Casts Fire IV/V, Firaga III/IV, Firaja, Graviga, Slowga, Sleepga, Bindga, Silencega, Addle. Resistant to ice. Bio III and Tidal Roar give about -40% attack.
- Drops: Ganesha's Mala, Ganesha's Mask, Atmacite of Eminence (#214, #343).

### Voidwrought
- Ballistic Kick and Eradicator. Thundaja. EA+Scherzo works after Eradicator (#818). Treasure Hunter may be broken on it (#671). Staggers are sometimes low tier. Drops Voidwrought Plate and Strendu Ring (#385).

### Celaeno
- About 70k HP. Behaves like an Iron Giant: 3 shadows on AoE, 300-900 AoE.
- Moves: Rending Talons, Shrieking Gale (full dispel), Wings of Agony (physical AoE, sleep/paralyze), Wings of Woe (through shadows, plague/silence), Ravenous Wail (high AoE), Typhoean Rage (below 50%, AoE, encumbrance + muddle).
- Casts Silencega, Slowga and an Aeroga III/Ga IV/Aeroja progression. Stunnable. Avatars (Garuda) can tank it. Drops: Phineus' Gun, Celaeno's Cloth, Langeleik, leg seals, Anhur Robe (rare).

### Aello
- 3 fairy adds. Shrieking Gale (full dispel plus hate reset) resummons the babies. Typhoean Rage from below 75%. Kaleidoscope Fury below 50%. Loses about 25% defense with babies dead.

### Uptala
- Yaksha only, so constant PDT -50%. Oblivion can be chained twice. Sakra Storm below 50% is ST20 plus paralyze, muddle and hate reset.

### Bismarck (Pugil)
- Pugil adds pop more over time. A late-fight damage penalty grows as the fight wears on. Ranged damage and Wildfire were not affected.

### Morta
- 6 Rafflesia adds. Full Bloom heals about 10%. Frond Fatale, Beautiful Death, Atropine Spore, Night Stalker, Deracinator. Multiple Chainspells; needs a stun rotation.

### Qilin (Zilart T3)
- Adds arrive one at a time, no resummon, all out by about 10 min: Byakko (blind aura, high evasion), Suzaku (paralyze aura, en-amnesia, wind damage with silence), Genbu (high defense), Seiryu (unknown aura). Adds and Qilin do not use 2hrs.
- Best plan: don't kill the adds; tank them aside and kill Qilin in about 5 minutes (#1199, #1189). Summons can occur while it is staggered (#1507).
- Strong regen. TP moves single target: Tail Smash, Tail Swing, Deadly Hold (2500+); shadows absorb them (#1503). Heat Breath is breath-based. Heavily resistant (not immune) to hate manipulation (#3400). High earth resist (#2163).
- Drops: Houyi's Gorget (very common), Fajin Boots, Lux Pugio, Coruscanti, Atmacite of Promises (mislabeled "Exhortation" in the client, #1119).

### Pil (Behemoth's Dominion, Jeuno T4)
- Roughly 200k+ HP, very resistant to damage. Resists earth, water, ice, dark; takes wind, fire, lightning, light fine (#1312).
- **Bishop's Gambit**: heals (over 25k seen across the fight) and then grants a Physical Shield. Below 50% (increasingly as HP drops) it sometimes gives full invincibility (everything does 0) until a weakness stagger is procced (#1081, #1082, #1091). The shield returns right after it falls, so stun right after the stagger. 16 shields were seen in one fight (#1214). About 1000 damage through the shield drops it (#1154). The shield is vulnerable to exactly one of: magic, slashing, melee piercing, ranged, H2H, impact (#1200, #1208). Quick Draw, Twilight Scythe, Shield Bash ignore it (#1154, #1167, #1168); Spirits Within does not (#1170).
- Moves: Shah Mat (Terror + Doom gaze; facing away or turning helps, #1663), Flank Opening (about 1k AoE + DEF-down aura), Malign Invocation (amnesia), Kaustra (only below 50%, 700-1000 plus about 150/tick DoT, #1087). Magic is weak. Resists stun even with Ascetic (#1090).
- EA + Scherzo make him easy to tank (#1321). Strategy: 2-3 COR with Quick Draw, few melee, 3 WHM.
- Drops: Aliyat Chakram, Dilaram's Sollerets, Toci's, Pil Tuile. Atmacite of Latitude.

### Akvan
- Ahriman type, easiest T4. Deathly Glare is an AoE death gaze; facing away still takes 300-500 AoE (#1222, #1223). Casts Death. Spams Magic Barrier; Death and the gaze can be stunned unless Magic Barrier is up, though Shock Squall stuns through it (#1312). Gains -50 PDT while casting (#1816). Low resistance to BLU debuffs (#1460). Fool's Drink blocked its Death (#1743).
- Drops: Heka's Kalasiris, Omphalos Bullet, Sceamol Band, Akvan's Pennon, Moon Amulet (trash, #1095).

### Gaunab / Ocythoe
- Gaunab: Immolating Claw. Ocythoe: lightning spells, Keraunos Quill, about 170k HP. Cruor 7,500 each (#1884).

### Ig-Alima (Valkurm Dunes)
- Moves: Oblivion's Mantle (AoE weakness + doom), Bolt of Perdition (AoE, mute + amnesia), Searing Halitus (fire AoE about 700 with Shell V), Crippling Rime (frontal ice AoE, possible hate reset), Diluvial Wake (conal, stats down), Divesting Gale (encumbrance), Kurnugi Collapse (low AoE, accuracy down).
- Casts Ice/Blaze/Shock Spikes, and Dread Spikes at low HP. Regain is high; regen about 1% per minute. Stunnable. Random -DT spurts and strong -DT near death (#2005, #2011). Random hate (#2025). "Qilin +1" (#1926).
- Drops: Hoarfrost Blade, Ogier's Surcoat, Wroth Scythe, Dhampyr Sword, Borealis. Cruor 10,000.

### Kalasutrax
- About 170k HP. Raksha-based TP, water spells. Raksha Stance MDT reports conflict: none (#1554) vs "very high PDT and MDT" (#1718); the stance dispels buffs (#1753).
- Yama's Judgment: AoE damage + 5-count Doom (#1743). Death spell. Gains PDT around stances (#2014).
- Strategy: stun Raksha Stance and Yama's Judgment. Wildfire + Light skillchains + 5-7 BLM. Embrava (#2141).
- Fanatic's blocks its TP (#2149). AoE about 1000-1100 to the target, 600-700 to others after the AoE nerf (#2386). Console DC/black-screen bug (#1740, #1756). Cruor 7,500.

### Botulus Rex
- About 150k HP, 50 HP/tick regen. Chymous Reek, Sloughy Sputum, Crowning Flatus, Rancid Reflux, Just Dessert, Gnash 'n Guttle, Slimy Proposal (AoE charm plus Dia at low HP).
- Casts all -ja plus Meteor, multiple Chainspells that focus one target. Bio aura. Melee add effects: amnesia, HP max down, knockback or stun. Hate reset on melee/TP. Weak to lightning; Zantetsuken works; stun doesn't build resistance (#1921). Fool's Drink during Chainspell. Drops: Athos's Tabard, Supernal Knife, Gerra's Staff. Cruor 10,000.

### Fjalar (Attowha Chasm, Dvergr)
- Spawns a Bloody Skull add after each Hellsnap (AoE stun), up to 3 (#2425, #2633). Skull adds cast Ga III, Sleepga, para, stun, stone, curse; hate is erratic.
- Moves: Hellsnap, Thundris Shriek (AoE terror/damage), Dunur Strike (low AoE), Bifrost Squall (high AoE), Cackle (MDEF down and other debuffs; must be removed, #2618).
- **Meteor** around 40-42% wipes alliances (#2509, #2506); 1.8k through Shell (#2425). May gain Meteor only below about 25% or 15% (#2502, **[theory]**). Instant casts.
- Strategy: keep it procced; Fool's under about 20% (#2502); Aegis PLD plus ranged damage; Embrava zerg with twilight gear.
- Drops: Penelope's Cloth (#2653), Corvine Abjuration: Legs (#2576).

### Provenance Watcher (Crystal Dragon)
- About 350k HP (#2807). Needs three Petrifacts (#2682). No area hate; fetter hate is independent (#2837). Aggros if you wipe (#2682).
- Fetters: 8 colors, one per element, each with an aura (dark: doom; light: ST20, #3027). Damage cut by fetter count: 1 fetter 50%, 2 fetters 80%, 3 fetters 99% (#2781). Vulnerabilities: dark/fire/earth/water to physical, wind/ice/thunder/light to magic (#2771).
- Fetters pop when it casts an elemental spell, and one popped even when the spell was stunned (#2865, #2873, #3139). Not after Addle. Can pop before 50% (#3029).
- Spells: tier III-V single nukes, -ga III-IV, Comet, Meteor, Holy, Holy II, AoE Diaga III/Silencega/Blindga/Addle/Stun. List scales by light color: White Tier III; Yellow Tier IV, -ga III, Holy, Comet; Red Tier V, -ga IV, Holy II, Meteor (#2781).
- TP: Acicular Brand and Orogenesis (physical). Crystallite Shower (Dia+Slow+Addle), Phason Beam, Graviton Crux (absorbs HP and one attribute), Crystal Bolide (Obliviscence+Terror), Fragor Maximus (weakness plus self-intimidation) (#3027, #2964). Tail about 900-1200 AoE, claw 600-900, head about 250-300 AoE magic damage.
- Drops: Drachenhorn, Hyaline Hat, Tessera Saio, Sanus Ensis, Plenitas Virga, Adamas, Meteor/Arise scrolls (#2798, #2846). Atmacite of Provenance.

### Radiance chambers (Pil/Sarbaz, Asb/Rukh, Shah/Wazir)
- Beguiling: Pil > Sarbaz. Seductive: Asb > Rukh. Maddening: Shah > Wazir (#2838).
- Wazir: False Promises (AoE charm); the charm add effect persists regardless of drinks (#2727). Possibly not used while Shah lives (#3075). Meteor too.
- Shah: Shah Mat. Asb: Unchivalrous Stab (all stats down, TP down, HP/MP down, #2746).
- Sarbaz: Pawn's Penumbra (#3077). Drops: Wyrdstrand, Scarletite Ingot, Wohpe's Sabots (#2746, #2906).

---

# Part B — General mechanics ("other information")

## B1. Alignment lights and weakness (stagger)
- Lights: blue, red, yellow, green, white. Blue drives chest slots. Red raises unique-item chance. White requires highly vulnerable procs; about 4 of them for 100%.
- Observed final tallies: Cottus B270/R390/Y225/G225/W75 (#6); Hahava B250/R500 (#214); Moira B450/R500/Y325/G225/W75 (#176); Ushumgal B150/R170/Y135/G110/W0 (#52).
- Caps: blue about 350 (525 with cells and periapt); red 500. Three cells raise blue and red by 150 each, which was the maximum item contribution (#6, #210).
- Treasure Hunter is multiplicative: (base + cell) × (1 + TH%) + periapt, capped at 500 (#671). TH7 gave +7%.
- Stagger tiers NQ 20% and 40%, HQ 100% and 200%. A proc landed during a spell or TP move gives the higher tier (#822, #823, #827).
- Only 2 "highly vulnerable" weaknesses at a time (#325). Pool of about 2 HQ plus 4-6 NQ (#2221).
- Aura message "The aura of your foe suddenly changes" (#2312).
- Stagger examples: Seymour: Burning Blade, Spirit Taker; Fire III, Tachi: Jinpu, Aspir II, Lightning Threnody. Lorbulcrud: Blizzard III, Sanguine Blade, Magic Finale, Earth Threnody (#154). Elemental stagger spells follow a day-1/day/day+1 pattern like Abyssea (#207).
- Synchronic Blitz: no clear cap, stagger time stacks (#1298, #823). Alignment blitz from killing adds (Tangaroa, #982).
- 2012-01 nerf: AoE damage reduced for non-targeted characters, pets included (#2249). Ig-Alima and Botulus Rex initially lacked the higher stagger tier on spells; fixed 2012-02-21 (#2003, #2405).
- Later changes: weakening items, void clusters, and a weakness-by-fee system (#3160, #3322).

## B2. Drinks and defenses
- Fanatic's Drink blocks physical TP moves; Fool's Drink blocks magic. Neither blocks everything: Gravitic Horn and Whiteout-style percent/special moves pass (#2147); Fanatic's still allows Thundris Shriek terror (#3310).
- Fool's blocked Death from Akvan (#1743). Fool's means Meteor deals no damage but you get stunned (#798).
- EA (Earthen Armor) + Sentinel's Scherzo give about -75% DT (#237); useful only on specific moves (#818).
- Shell V and MDT sets survive Meteor (#801).

## B3. Rewards
- Cruor: Botulus and Ig-Alima 10,000; Gaunab, Ocythoe, Kalasutrax 7,500 (#1884). T1 base 5000-6000.
- Drops are independent per player. Pouch size 3-15 (#2298). Roughly 1 pouch per 18 people.
- KI petrifacts are route-specific: Bastok and Tavnazia give Seductive; Windurst and Aht Urhgan give Maddening; San d'Oria and Zilart give Beguiling; Jeuno routes are random. Everyone in the alliance gets the KI (#2778, #2785, #2829).
- Silver Mirrors and riftsand were added to lower Jeuno tiers later (#1357, #1940). T1 drops share abyssite/periapt per path (#45, #150).
- Only the popper loses the voidstone on a wipe (#1205, #1207). Clears must be done in tier order; credit is for your current tier only (#2231, #2234).

## B4. Hate and add behavior
- Pet-owner quirk: when a summoner or similar releases the pet, newly summoned adds target the owner (#3306).
- Fjalar's and some T1 adds spawn with hate (#3307). Qilin is heavily resistant to hate manipulation (#3400).
- Hate resets appear on Sarimanok's combo, Aello's Shrieking Gale, Uptala's Sakra Storm, Botulus Rex's melee/TP, possibly Ig-Alima's Crippling Rime.

## B5. Rift locations seen (sample)
- East Ronfaure rifts: H-5, I-6, G-10 (#6). Maze of Shakhrami: D-8, I-8, H-5 (#44).
- Jeuno T4: West Ronfaure H-6/H-8/H-10; South Gustaberg J-10/K-7/L-9; East Sarutabaruta G-11/H-6/J-5. T5: La Theine E-5/I-11/L-8; Konschtat G-4/I-11/J-8; Tahrongi Canyon I-9/I-12/J-6. T6: Gaunab (Vunkerl [S]) F-5/G-8/G-13; Ocythoe (Grauberg [S]) D-14/G-7/G-11; Kalasutrax (Fort Karugo-Narugo [S]) D-12/I-11/K-8 (#1836). Ig-Alima F-8, K-8 known so far (#1837).
- **Do not use these as IDs or coordinates** — verify against DAT/capture before touching SQL.

## B6. Platform and misc
- Console users black-screened or DC'd at Kalasutrax (#1740, #1756, #2392).
- A Caturae-style add effect and ability-timer reset before Provenance Watcher (#3042).

---

# Part C — Cross-check against the Krabimanjaro implementation

| Our guess | Thread evidence |
|---|---|
| Defense and evasion boost past 50% HP | Supported (#231) |
| Regain at low HP | Not mentioned; mark unverified |
| Venom Shower repeated | Supported (#229, #791); double use at low HP |
| Cruor, lights, TH formula, stagger tiers | Supported (#6, #671, #822) |
| Weakness values, blitz trigger, clearance range, status ids, Pyxis options | Not covered by the thread; remain unverified |

# Open questions
- Exact Raksha/Yaksha MDT/PDT behavior on Kalasutrax (conflicting).
- Vanasarvik's Dark Recital effects; Yalungur's second drop.
- Whether Fjalar's Meteor is gated by HP threshold or by an hidden timer.
- Provenance Watcher: are there 2 white procs (one before wings, one after)? Rumor only (#3420).
