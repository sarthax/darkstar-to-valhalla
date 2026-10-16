# Client-id verification (2026-10-15)

Sources: Windower `Resources` (buffs.lua, job_abilities.lua, action_messages.lua, client-derived), Valhalla client DATs via `model_schedule_dump.py`, existing DSP ability rows.

| Item | Result |
|------|--------|
| Colure Active = 612 | VERIFIED (buffs.lua id 612 "Colure Active") |
| GEO aura effects 539-567, 580 | VERIFIED: all 30 names match client buff names (Regen..Weight, Haste) |
| Embolden effect 534 | VERIFIED |
| Ability ids (30 slice rows) | VERIFIED: DSP id = client id - 16 for every row; names and recast ids match job_abilities.lua |
| Message ids (message1) | VERIFIED by text for all non-zero values (100, 102, 110, 306, 319, 320, 663, 664, 667-672); basic msgs 18/47/87 verified |
| message1 = 0 rows | Single-target path falls back to "uses ability" (msg 100); fine for Bolster/Full Circle |
| Concentric Pulse / Mending Halation / Radial Arcana messages | FIXED: scripts now `setMsg` 110 (damage), 102 (HP recovered), 451 (MP regained); previously showed plain "uses" with no number |
| Ability animation ids | NOT verifiable against client DATs with current tooling. Circumstantial: RUN neighbours already in DSP (Swordplay 299, Elemental Sforzo 302, One for All 301, Vivacious Pulse 327) match LSB values and Embolden 300 fits the sequence; no slice animation collides with a different existing DSP ability. Still needs an in-game look. |
| Luopan model ids 2850-2856, 2865 | PARTIAL: flat model offset (98239+id) resolves 2850-2854 to ROM/342 DATs but not 2855, 2856, 2865, and those DATs did not parse as model files. Offset is a known-unresolved tool gap (TOOLING_OVERVIEW). Values are LSB's; confirm by spawning each element in-game. |
