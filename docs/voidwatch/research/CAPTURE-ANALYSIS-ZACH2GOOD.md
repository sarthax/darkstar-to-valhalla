# Capture analysis — zach2good Raguza captures (34 zips, toolkit ids 695-728)

Evidence tag **[C]** = observed directly in capture text logs (`caplog/*.txt`, `eventview/simple.log`) this session.
Raw logs: `Playthrough Captures/voidwatch_captures/extracted/<label>/Raguza/`. Retail-ish source (Windower addons), 2021.

## Toolkit ingestion gap
Toolkit reports 0 eventview packets / 0 ki events for these (Raguza layout: `eventview/simple.log` + `caplog`). The data IS present and readable
in the text logs; analysis below was done with an ad-hoc parser. Toolkit parser fix = optional follow-up (not needed to proceed).

## [C] Fight loop (identical across ~18 NM captures) — validates the Abyssea-qm-style spawn (Q3)
1. Player clicks **Planar Rift** NPC. Server sends `0x034` event with params; the client shows
   "You feel a mysterious energy..." / "The voidstone resonates with the <abyssite>. You may commence the Voidwatch operation at will."
2. Player answers **Option 1** (commence; Option 0 = cancel) -> NPC chat (0x036, zone-specific message id) "A fiend materializes from the planar rift!",
   "<Player> gains clearance to participate... One voidstone expended.", "You have 30 minutes (Earth time) to complete the battle."
   Status Voidwatcher (475) is applied (it "wears off" after the Pyxis is closed).
3. NM is an **ordinary zone mob entity** (e.g. Akupara id 17175252, rift 17175424) — NO instance, NO zone change. Fits dynamic `SpawnMob` from the Rift. Some NMs bring adds
   (Abununnu: 2x Gloam Servitor; Tsui-Goab: Bloodswiller Flies).
4. Some fights print "Synchronic blitz commences! Assail the fiend with all your strength!" ... "Synchronic blitz complete." (Cottus, Kholomodumo, Lorbulcrud, Melancholic Moira, Ogbunabali) — occurs ~8-45 s into fight, lasts ~7-30 s.
5. On kill: **Riftworn Pyxis** NPC (= rift id +3, a pre-existing static NPC that becomes active) sends `0x034` event; messages "Raguza gains N limit points", "obtains N cruor (Total: ...)",
   "Final Spectral Alignment Blue/Red/Yellow/Green: X%", and for lucky rolls "obtains the Atmacite of ..." / "periapt".
   Player responds **Option 9** (done) or **Option 10** (take items) -> items listed via chat ("obtains the crystal petrifact!", etc.), then "All reward items have been relinquished." (0x036).

## [C] Event/CSID map (zone-local csid, observed)
| NPC | CSIDs | Notes |
|---|---|---|
| Planar Rift | 6000 / 6001 / 6002 | One per rift of the 3 in a zone (rift index 0/1/2). Opts: 1 = commence, 0 = cancel. |
| Riftworn Pyxis | 6003 / 6004 / 6005 | Pairs with rift index (pyxis csid = rift csid + 3). Opts: 9 / 10. |
| Voidwatch Officer | 963, 1024 (+ 9, 80 generic) | Opts seen 0,1,3,4,5; Opt 5 on 963 = obtain stratum abyssite KI |
| Atmacite Refiner | 962, 1023 (+ 8, 79) | Opts 0,1; teleport-to-site service costs 1000 cruor |
Zone note: Planar Rift event params differ in HQ zones (zone-specific cs ids may be offset). Message ids (0x036) are zone-text ids (7396, 8093, 11109 ...). Full per-zone resolution = step 3.

## [C] Planar Rift 0x034 params layout (8 params)
`[p1, p2, 0,0,0,0, p7, p8]`: **p8 = abyssite KI id held/offered** (366-369 crimson I-IV, 370-373 indigo, 374-377 jade, 2060 hyacinth; verified vs client KI table);
**p7 = player's current cruor total** (matches "Total:" after the following fight); p1/p2 = bit flags (14/6/2062, 16/18) — meaning TBD (likely which paths/KIs available).

## [C] Pyxis 0x034 param p1 — a reward bitfield/ids (866, 749, 3508, 4118...) — meaning TBD; ties to which item/KI rewards are in the pyxis.

## [C] Observed rewards (retail, abyssite tier -> cruor)
Tier I 5000 cruor; II 5500; III 6000; IV 6500 (with +0% alignment). With alignment modifiers: 209%/309% blue/red -> 11250 cruor; 155%/350% -> 12300; 104%/204% -> 6270; 118%/218% -> 7040; 211%/111% -> 9660;
Abununnu (hyacinth, 350/350) 16875. So cruor scales with the green/alignment percentage as the wiki digest claimed.
"gains N limit points" 6000 at tier III/IV seen (Akupara).
Final Spectral Alignment is printed as Blue/Red/Yellow/Green percentages (only two lines captured per grab by the log script; see caplog).

## [C] Voidstone / abyssite economy
Officer gives crimson/indigo/jade stratum abyssite KI ("Obtained key item: Crimson stratum abyssite."), then voidstone ("Obtained key item: 1 voidstone!", "...2 voidstones!" -> count in KI name). 
Atmacite Refiner: teleport service 1000 cruor to an operation site.

## Gaps
- Weakness/stagger messages (the "weakness" window) were NOT seen in these 6 text greps — logs are mostly quick kills; likely appear in actionview/packetviewer 0x028/0x029 or specific message ids. Need targeted pass.
- Pyxis p1, Rift p1/p2 meanings; Pyxis reward item selection (which 1-6 items) — needs the 0x036 item messages vs pyxis contents.
- Hyacinth/amber captures (Abununnu, Tsui-Goab) are from Aht Urhgan-era zones with different id spaces (ID View addon) — ignore for MVP.
- Single recorder (Raguza) + trusts; multiplayer pyxis fairness not observable.
