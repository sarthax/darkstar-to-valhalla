-----------------------------------
-- Area: Ilrusi Atoll
--  Mob: Imp
-----------------------------------
-- 2026-09-14: `mixins = {...}` (Topaz's auto-apply table) is dead code in old-dsp-reference --
-- confirmed nothing in this codebase's C++ reads it. Wired to ImpMix.onCriticalHit via the real
-- onCriticalHit(mob) engine callback instead -- see scripts/mixins/families/imp.lua's own header.
require("scripts/mixins/families/imp")
-----------------------------------
function onCriticalHit(mob)
    ImpMix.onCriticalHit(mob)
end

function onMobDeath(mob, player, isKiller)
end

