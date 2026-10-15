# RUN Lua port gaps (rune_fencer.lua draft)
Draft: scripts/globals/job_utils_draft/rune_fencer.lua (not loaded).

## Missing C++ Lua bindings in DSP (lua_baseentity.cpp)
DONE (slice): getActiveRuneCount, getHighestRuneEffect, getNewestRuneEffect, removeOldestRune, removeNewestRune, removeAllRunes (container + Lua bindings, syntax-checked with cl /Zs). STILL MISSING: getAllRuneEffects, takeSwipeLungeDamage, getJobPointLevel.
Job points are unused in DSP: replace jp bonuses with 0 (or stub getJobPointLevel to return 0).

## Missing Lua constants
xi.merit.* (RUNE_ENHANCE, BATTUTA, RAYKE, PFLUG_EFFECT, VALLATION_EFFECT, INSPIRATION, SLEIGHT_OF_SWORD) - DSP merit.h has some C++ enums; check Lua exposure.
xi.msg.basic.* (REQUIRE_RUNE, VALIANCE_GAIN_PARTY, JA_RECOVERS_HP, ...) - ids 660-672 unverified vs client.
xi.spells.damage.* helpers (calculateAbsorption, calculateDayAndWeather, ElementalAffinity/Staff/MagicBurst bonuses, Nullification) - DSP has no damage_spell module; Lunge/Swipe need an equivalent from magic.lua.
xi.jobAbility.LUNGE/VALIANCE need ABILITY_* entries (swipe 328 absent in ability.h).

## Semantic trap
LSB SDT mods (base 10000) share ids 54-61 with DSP FIRERES..DARKRES (1000ths damage reduction). Vallation/Valiance/Gambit/Rayke/Pflug need an explicit scale decision before port.
