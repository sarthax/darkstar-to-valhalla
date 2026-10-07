# Item script health report

Generated 2026-10-04 21:33 for `D:\Claude\dsp-master`.

## Summary

- Items with a proc switch (effect 431): 260 (239 behavior, 21 missing)
- Item script files: 1813 (1783 behavior, 1 check-only, 29 stub)
- Script files matching no item name: 135
- Repair plan for the broken items: 1 misnamed, 3 manual, 2 generate, 14 needs-data, 1 no-lsb-data

## Why these items never proc

On this server an item's additional effect only runs if `scripts/globals/items/<name>.lua` defines `onAdditionalEffect`. These items have the proc switch (mod 431) set but no such script, so the switch does nothing. LandSandBoat runs the same effects from item data instead of per-item scripts, so it has no script file to copy; it only supplies parameters, and only for some items.

## Items with a proc switch but no working script

| Item | ID | Server state | LSB proc type | What LSB supplies | Plan |
|---|---|---|---|---|---|
| poison_kukri_+1 | 16489 | missing | DEBUFF | chance=15, status=3, power=4, duration=30 | **misnamed** — a script for this item exists as `scripts/globals/items/poison_kukri _+1.lua` but the server looks for `poison_kukri_+1.lua`; rename it |
| oynos_knife | 16504 | missing | SELF_BUFF | chance=10, status=33, power=15, duration=180 | **manual** — LSB proc type SELF_BUFF is not one this tool generates; needs a hand-written script (LSB values listed for reference) |
| holy_sword | 16581 | missing | DAMAGE | damage=10, chance=5, element=7 | **generate** — every value comes from LSB; chance/amounts are LSB's, not retail-verified on DSP |
| holy_sword_+1 | 16816 | missing | DAMAGE | damage=10, chance=10, element=7 | **generate** — every value comes from LSB; chance/amounts are LSB's, not retail-verified on DSP |
| moepapa_mace | 17069 | missing | DEBUFF | chance=10, status=155, duration=12 | **needs-data** — LSB marks this as DEBUFF but does not supply: power. Not guessed. |
| metasoma_katars | 18784 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |
| grotesque_cesti | 18785 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |
| cadushi_grip | 18810 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |
| twilight_knife | 19132 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |
| mantodea_harpe | 19140 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |
| darkling_bolt | 19196 | missing | - | nothing | **no-lsb-data** — LSB has no additional-effect data for this item |
| jinx_discus | 19261 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |
| ban | 19296 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |
| erebuss_lance | 19315 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |
| fetter_lance | 19316 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |
| jugo_kukri_+1 | 20609 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |
| sangarius | 20611 | missing | HP_DRAIN | nothing | **manual** — LSB proc type HP_DRAIN is not one this tool generates; needs a hand-written script (LSB values listed for reference) |
| sangarius_+1 | 20612 | missing | HP_DRAIN | nothing | **manual** — LSB proc type HP_DRAIN is not one this tool generates; needs a hand-written script (LSB values listed for reference) |
| cronus | 20904 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |
| mafic_cudgel | 21102 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |
| staccato_staff | 21166 | missing | DAMAGE | nothing | **needs-data** — LSB marks this as DAMAGE but does not supply: damage, chance, element. Not guessed. |

Plan key: **generate** = a draft script can be written from LSB values; **needs-data** = LSB knows the proc type but not the numbers (get them from a retail source; nothing is guessed); **manual** = proc type this tool does not generate; **no-lsb-data** = LSB has nothing; **misnamed** = a working script exists under the wrong filename, rename it.

## Script files that are stubs or check-only

| File | State here | State in LSB | TODO marker |
|---|---|---|---|
| `scripts/globals/items/air_rider.lua` | stub | stub |  |
| `scripts/globals/items/airborne.lua` | stub | stub |  |
| `scripts/globals/items/angelwing.lua` | stub | stub |  |
| `scripts/globals/items/angler_stewpot.lua` | behavior | stub | yes |
| `scripts/globals/items/beef_stewpot.lua` | behavior | stub | yes |
| `scripts/globals/items/black_curry_bun.lua` | behavior | stub | yes |
| `scripts/globals/items/black_curry_bun_+1.lua` | behavior | stub | yes |
| `scripts/globals/items/bowl_of_loach_gruel.lua` | behavior | stub | yes |
| `scripts/globals/items/bowl_of_loach_slop.lua` | behavior | stub | yes |
| `scripts/globals/items/bowl_of_nashmau_stew.lua` | behavior | stub | yes |
| `scripts/globals/items/bowl_of_sutlac.lua` | behavior | stub | yes |
| `scripts/globals/items/bowl_of_sutlac_+1.lua` | behavior | stub | yes |
| `scripts/globals/items/brilliant_snow.lua` | stub | stub |  |
| `scripts/globals/items/chocolate_cake.lua` | behavior | stub | yes |
| `scripts/globals/items/crab_stewpot.lua` | behavior | stub | yes |
| `scripts/globals/items/cracker.lua` | stub | stub |  |
| `scripts/globals/items/crackler.lua` | stub | stub |  |
| `scripts/globals/items/datechochin.lua` | stub | stub |  |
| `scripts/globals/items/dream_boots_+1.lua` | behavior | stub | yes |
| `scripts/globals/items/dream_mittens_+1.lua` | behavior | stub | yes |
| `scripts/globals/items/falling_star.lua` | stub | stub |  |
| `scripts/globals/items/festive_fan.lua` | stub | stub |  |
| `scripts/globals/items/flask_of_muting_potion.lua` | stub | stub |  |
| `scripts/globals/items/gateau_aux_fraises.lua` | behavior | stub | yes |
| `scripts/globals/items/goshikitenge.lua` | stub | stub |  |
| `scripts/globals/items/green_curry_bun.lua` | behavior | stub | yes |
| `scripts/globals/items/green_curry_bun_+1.lua` | behavior | stub | yes |
| `scripts/globals/items/hushed_baghnakhs.lua` | behavior | no-lsb-script | yes |
| `scripts/globals/items/hushed_dagger.lua` | behavior | no-lsb-script | yes |
| `scripts/globals/items/kongou_inaho.lua` | stub | stub |  |
| `scripts/globals/items/konron_hassen.lua` | stub | stub |  |
| `scripts/globals/items/little_comet.lua` | stub | stub |  |
| `scripts/globals/items/maple_cake.lua` | behavior | stub | yes |
| `scripts/globals/items/marine_bliss.lua` | stub | stub |  |
| `scripts/globals/items/meifu_goma.lua` | stub | stub |  |
| `scripts/globals/items/melt_baselard.lua` | behavior | stub | yes |
| `scripts/globals/items/melt_claws.lua` | behavior | no-lsb-script | yes |
| `scripts/globals/items/melt_dagger.lua` | behavior | no-lsb-script | yes |
| `scripts/globals/items/melt_katana.lua` | behavior | no-lsb-script | yes |
| `scripts/globals/items/melt_knife.lua` | behavior | no-lsb-script | yes |
| `scripts/globals/items/melt_kukri.lua` | behavior | no-lsb-script | yes |
| `scripts/globals/items/midwinter_dream.lua` | behavior | stub | yes |
| `scripts/globals/items/muteppo.lua` | stub | stub |  |
| `scripts/globals/items/orange_cake.lua` | behavior | stub | yes |
| `scripts/globals/items/ouka_ranman.lua` | stub | stub |  |
| `scripts/globals/items/papillion.lua` | stub | stub |  |
| `scripts/globals/items/popper.lua` | stub | stub |  |
| `scripts/globals/items/popstar.lua` | stub | stub |  |
| `scripts/globals/items/prime_angler_stewpot.lua` | behavior | stub | yes |
| `scripts/globals/items/prime_beef_stewpot.lua` | behavior | stub | yes |
| `scripts/globals/items/prime_crab_stewpot.lua` | behavior | stub | yes |
| `scripts/globals/items/prime_seafood_stewpot.lua` | behavior | stub | yes |
| `scripts/globals/items/prized_angler_stewpot.lua` | behavior | no-lsb-script | yes |
| `scripts/globals/items/prized_beef_stewpot.lua` | behavior | stub | yes |
| `scripts/globals/items/prized_crab_stewpot.lua` | behavior | stub | yes |
| `scripts/globals/items/prized_seafood_stewpot.lua` | behavior | stub | yes |
| `scripts/globals/items/pumpkin_cake.lua` | behavior | stub | yes |
| `scripts/globals/items/ramblers_cloak.lua` | stub | stub |  |
| `scripts/globals/items/red_curry_bun.lua` | behavior | stub | yes |
| `scripts/globals/items/red_curry_bun_+1.lua` | behavior | stub | yes |
| `scripts/globals/items/rengedama.lua` | stub | stub |  |
| `scripts/globals/items/roll_of_buche_au_chocolat.lua` | behavior | stub | yes |
| `scripts/globals/items/roll_of_sylvan_excursion.lua` | behavior | stub | yes |
| `scripts/globals/items/seafood_stewpot.lua` | behavior | stub | yes |
| `scripts/globals/items/seito.lua` | behavior | no-lsb-script | yes |
| `scripts/globals/items/serving_of_black_pudding.lua` | behavior | stub | yes |
| `scripts/globals/items/serving_of_dusky_indulgence.lua` | behavior | stub | yes |
| `scripts/globals/items/serving_of_elysian_eclair.lua` | behavior | stub | yes |
| `scripts/globals/items/serving_of_golden_royale.lua` | behavior | stub | yes |
| `scripts/globals/items/serving_of_mille-feuille.lua` | behavior | stub | yes |
| `scripts/globals/items/serving_of_mont_blanc.lua` | behavior | stub | yes |
| `scripts/globals/items/shisai_kaboku.lua` | stub | stub |  |
| `scripts/globals/items/silken_sash.lua` | behavior | stub | yes |
| `scripts/globals/items/silken_siesta.lua` | behavior | stub | yes |
| `scripts/globals/items/silken_smile.lua` | behavior | stub | yes |
| `scripts/globals/items/silken_spirit.lua` | behavior | stub | yes |
| `scripts/globals/items/silken_squeeze.lua` | behavior | stub | yes |
| `scripts/globals/items/sparkling_hand.lua` | stub | stub |  |
| `scripts/globals/items/spirit_masque.lua` | stub | stub |  |
| `scripts/globals/items/summer_fan.lua` | stub | stub |  |
| `scripts/globals/items/twilight_cloak.lua` | check-only | stub |  |
| `scripts/globals/items/twilight_scythe.lua` | behavior | no-lsb-script | yes |
| `scripts/globals/items/twinkle_shower.lua` | stub | stub |  |
| `scripts/globals/items/wedding_bell.lua` | stub | stub |  |
| `scripts/globals/items/yellow_curry_bun.lua` | behavior | stub | yes |
| `scripts/globals/items/yellow_curry_bun_+1.lua` | behavior | stub | yes |
| `scripts/globals/items/yogurt_cake.lua` | behavior | stub | yes |

A stub that is also a stub in LSB is usually an item whose use effect is purely cosmetic or handled by the client; confirm per item before treating it as broken.

## Resolution status (final)

Valhalla is capped at level 90, so items above 90 were not worked on.

- **Ready to apply:** holy_sword, holy_sword_+1, twilight_knife, erebuss_lance, plus the `poison_kukri _+1.lua` rename (a complete script saved with a stray space in the filename).
- **Out of scope (level above 90):** oynos_knife (L93), moepapa_mace (L94), grotesque_cesti (L92), ban (L93), jugo_kukri_+1 (L99), sangarius (L99), sangarius_+1 (L99), cronus (L99), mafic_cudgel (L99), staccato_staff (L99).
- **Awaiting numbers, effect already wired (templates):** metasoma_katars, cadushi_grip, mantodea_harpe, darkling_bolt, jinx_discus, fetter_lance.
- **Stubs:** 27 of the 29 are intentionally empty (fireworks, fans, bells, masques); Twilight Cloak is working as designed; Rambler's Cloak's latent is already data; Flask of Muting Potion's behavior is unknown. See `stubs.md`.

### Source and assumption notes
- Erebus's Lance: 5% of hits, Empty-system targets only, damage = floor(TP / 14), light animation. Source: user-supplied wiki notes. No resistance or magic-attack-bonus adjustment is applied; TP is read when the proc fires.
- Twilight Knife: 5% activation, HP/MP/TP split 45:45:10, maximums 45/45/10 (BG Wiki). Assumption: HP and MP amounts are uniform from 1 to 45.
- Holy Sword and Holy Sword +1: chance and damage are LandSandBoat's, element confirmed by the wiki. Not retail-verified on this server.
- Mantodea Harpe: "Gravity" is `EFFECT_WEIGHT` in DSP (as `spells/gravity.lua` uses). Chance, power and duration are still needed.
- Cadushi Grip: chance set to 1% from a player observation (about 1 proc in 25 hits). Two observed drains (34 and 43 HP) are not enough to define a range, so the amount is blank.
- Metasoma Katars: the three statuses roll independently so several can land on one mob, with no resistance roll. Ignoring immunity cannot be done from Lua (it is enforced in C++ `StatusEffectContainer`) and would need an engine change. DSP has no `SUBEFFECT_BIND` constant, so the animation id for Bind needs confirming.
- LandSandBoat's data for several of these items is only a placeholder proc type with no numbers, so it is not evidence of the real effect.
- Twilight Knife's DSP data has Quad Attack 10 where the wiki says +3% (a separate data question).
