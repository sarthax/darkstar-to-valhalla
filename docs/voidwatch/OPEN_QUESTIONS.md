# Open Questions / Decisions

| # | Question | Needs | Status |
|---|---|---|---|
| Q1 | "Bring back" — did the DSP server/client era previously have working Voidwatch (user wording), or is this net-new? Local DSP has NPC rows + 453 inert VW NPCs but no scripts. | user | **ANSWERED 2026-10-06: No — Voidwatch is not working; net-new build.** |
| Q2 | Fidelity target: retail-faithful vs "working simplified" loop for MVP? | user | **ANSWERED 2026-10-06: as faithful as research/info allows; judgement calls (refine/simplify) when gaps arise, flagged.** |
| Q3 | Spawn mechanism for NMs in open-world zones (no instance): dynamic SpawnMob from Planar Rift trigger + despawn/cleanup; battle-participant tracking for Pyxis eligibility. Which DSP engine hooks exist? | investigate | **User 2026-10-06: OK if matches retail; validate with a few captures first.** Proposed: Abyssea qm model (SpawnMob+updateClaim from Rift) + pyxis pool; see DESIGN-INPUTS-ABYSSEA-SPAWN.md. Needs user ack + JA-weakness hook test |
| Q4 | Is a retail capture source available for Voidwatch (officer menus, fight, pyxis)? None exists locally. | user | **ANSWERED 2026-10-06: yes — Voidwatch captures + Discord-scraped packets exist; user will download and load into mission toolkit as part of build-out/validation.** Need: inventory what is available once loaded |
| Q5 | Which expansion-era is the DSP client? Voidwatch needs the Voidwatch-era client DATs (KI ids matched LSB so likely yes). Confirm Provenance/Walk of Echoes zone DATs. | verify | open |
| Q6 | Main "Voidwatch" wiki page missing from dump — OK to scrape (network/WebFetch) via `scrape_bg_wiki.py`? | user ok / run | **ANSWERED 2026-10-06: yes, scrape.** Done via MediaWiki API (`research/fetch_wiki_pages.py`) |
| Q7 | Priority order of paths/zones for first slice (suggest Ashen/Ru'Aun Aello, or a tier-I Crimson NM for simplicity). | user | **ANSWERED 2026-10-06: OK; start with the known-good, documented or already-built-out NMs (wiki-rich / LSB-complete), not necessarily one zone.** |
