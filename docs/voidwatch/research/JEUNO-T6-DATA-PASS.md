# Jeuno Stage VI [S] NMs: data pass (2026-10-09)

Fresh client pulls this session: `mission_toolkit.py <zone> --out-dir mission_reports` for the three zones. [V] = client dat.

| NM | Zone | Zone id | NM ids (x3 spawns) | Planar Rift ids | Riftworn Pyxis ids |
|---|---|---|---|---|---|
| Gaunab | Vunkerl_Inlet_[S] | 83 | 17117891-17117893 | 17118042-17118044 | 17118045-17118047 |
| Ocythoe | Grauberg_[S] | 89 | 17142449-17142451 | 17142618-17142620 | 17142621-17142623 |
| Kalasutrax | Fort_Karugo-Narugo_[S] | 96 [V; tracker had it blank] | 17171004-17171006 | 17171280-17171282 | 17171283-17171285 |

Rift grid refs (forum #1836, [B]): Gaunab F-5/G-8/G-13; Ocythoe D-14/G-7/G-11; Kalasutrax D-12/I-11/K-8. Rift xyz for Gaunab/Ocythoe are in NM-TRACKER.csv; Kalasutrax has none.

## Known [B/W]
- Jeuno Tier 6; cruor/EXP base 7,500 each (#1884). Kaleidoscopic Fury 2758 is commented out in DSP mob_skills (SKILL-AUDIT.md), used by Ocythoe.
- Ocythoe: lightning spells, Keraunos Quill (AoE, paralyze, weapon-slot encumbrance), Wings of Woe, ~170k HP, drops incl. Rubeus Bandeau (third drop, #1770).
- Gaunab: Immolating Claw; fire theme (atmacite of the Slayer).
- Kalasutrax: "green Hahava", Raksha TP moves + Raksha: Vengeance, water spells, ~170k HP, no MDT-50% after stance, DSP skill list differs (16 vs 18, SKILL-AUDIT.md). Skills 2501/2555 are commented out.
- Atmacites: Ocythoe 1824 Skyblaze, Gaunab 1825 the Slayer, Kalasutrax 1826 the Adamant (wired via cfg.atmacite once built).

## Still missing (do not guess)
- Stratum abyssite path/tier needed to pop (tracker: blank for all three; Botulus Rex is White VI 1452).
- Level, jobs, HP, mods, skill/spell lists, drop rates (ffxidb), message ids (zone dialog pulled, not yet matched), rift xyz for Kalasutrax, `!checknav` on all rift positions.

## 2026-10-09 base build (placeholder)
Gaunab / Ocythoe / Kalasutrax built as base NMs: lights framework, 30 min timer, white-gated atmacite (1825 / 1824 / 1826), NO drops, no custom skills or spells.
- Files: `scripts/zones/{Vunkerl_Inlet_[S],Grauberg_[S],Fort_Karugo-Narugo_[S]}/{mobs,npcs}`; SQL `sql/slices/voidwatch-vwnm/jeuno_vi_s_base.sql`.
- Verified [V]: rift/pyxis csids 6000-6005 and all message ids (Valkurm z103 minus 3298 / 3033 / 3127, every id text-matched in the zone's fresh dialog.yml).
- PLACEHOLDER [D]: gating (White VI + Voidstone), level 119-120 and HP 161800 (Ig-Alima; Botulus Rex is 94-95 / 145000), rift event params (Ig-Alima's capture), cruor base.
- Fixed: Kalasutrax spawn rows 2/3 were at (0,0,0) (never load); Gaunab pyxis 17118046 y.
- Not done: `!checknav` on the rift positions, drops, skills/spells.
