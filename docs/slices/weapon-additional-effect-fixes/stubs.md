# The 29 stub script files

A stub is an empty `onItemUse`/`onItemCheck`. Most are correct as stubs.

## Intentional, no repair needed (27)

Intentional. Fireworks/fans/bells/masques only play a client-side animation or nothing; LandSandBoat's file is the same empty stub. No repair.

`air_rider`, `airborne`, `angelwing`, `brilliant_snow`, `cracker`, `crackler`, `datechochin`, `falling_star`, `festive_fan`, `goshikitenge`, `kongou_inaho`, `konron_hassen`, `little_comet`, `marine_bliss`, `meifu_goma`, `muteppo`, `ouka_ranman`, `papillion`, `popper`, `popstar`, `rengedama`, `shisai_kaboku`, `sparkling_hand`, `spirit_masque`, `summer_fan`, `twinkle_shower`, `wedding_bell`

## Individually reviewed (3)

- **flask_of_muting_potion**: Unknown behavior. Wiki says only 'A powerful silencing potion enhanced with anima', valid target Self, no numbers. Do not guess; needs retail capture/data.
- **ramblers_cloak**: Not a script problem. Its STR+5 latent is already data (item_latents 11312, TP>=100%). The 'cannot equip headgear' restriction is not implemented in any DSP data; stub file is harmless.
- **twilight_cloak**: Working as designed. onItemCheck grants/removes the 'Impact' spell on equip; check-only is the correct shape for that mechanism.
