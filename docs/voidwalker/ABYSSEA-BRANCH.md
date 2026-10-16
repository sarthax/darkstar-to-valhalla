# Voidwalker Abyssea branch (documented only, not built)

Decision 2026-10-16: leave Valhalla's customised Abyssea zones untouched; revisit after the overworld path is finished and tested.

Sources: FFXIclopedia category `Voidwalker Notorious Monsters/Abyssea` (30 content pages, stored in `ffxi_zone_database.db`) cross-checked with BG Wiki (Clear/Colorful Demilune Abyssite, Dark/Fire/Ice Elemental pages). Not in LSB; DSP only references the key items. Key item ids are identical in LSB and DSP.

## Structure

Same idea as the overworld, but with one path per Abyssea zone (9 zones), three tiers each: rest on top of the NM with the pop item.

- Tier I: pop with **Clear Demilune (1564)**; kill has a chance to drop **Colorful Demilune (1565)**.
- Tier II: pop with Colorful Demilune; kill has a chance to drop the zone's **colour** Demilune.
- Tier III: pop with the colour Demilune (shatters on pop); drops an **Atma**.
- After Colorful the player is locked into that zone's path (no cross-zone chaining), as with the overworld colours. Unlike the overworld, there is no merge into a single Black NM.

## Paths

| Zone | Tier I (Clear) | Tier II (Colorful) | Colour KI | Tier III | Atma |
|---|---|---|---|---|---|
| Attohwa | At'euvhi | Es'euvhi | Jade (1649) | Lusca | Atma of the Demonic Skewer |
| Misareaux | Mi'ghrah | Mx'ghrah | Sapphire (1650) | Tristitia | Atma of the Bludgeoning Brute |
| La Theine | Meditator | Brooder | Scarlet (1566) | Ruminator | Atma of Eternity |
| Konschtat | Meanderer | Depths Digester | Azure (1567) | Hadal Satiator | Atma of the Beyond |
| Altepa | Fire Elemental, Earth Elemental | Koios | Emerald (1652) | Brulo | Atma of the Burning Effigy |
| Uleguerand | Ice Elemental, Water Elemental | Chione | Vermillion (1653) | Ogopogo | Atma of the Lake Lurker |
| Grauberg | Air Elemental, Dark Elemental | Gamayun | Indigo (1654) | Maere | Atma of the Endless Nightmare |
| Vunkerl | Vu'zdei | Hm'Zdei | Crimson (1651) | Ketea | Atma of the Demonic Lash |
| Tahrongi | Hungerer | Yearner | Viridian (1568) | Usurper | Atma of the Siren Shadow |

## Notes

- Altepa, Uleguerand and Grauberg Tier I are ordinary elementals (Fire/Earth, Ice/Water, Air/Dark) that happen to drop the upgrade; FFXIclopedia files them under the category.
- Hadal Mirror (Konschtat) is an add, not a path NM.
- Tier/KI mapping extracted from page text; no build until the scope decision. Open: spawn locations (flux/conflux grid refs are on each page), drop rates, HP and abilities per NM.
