-----------------------------------
-- Spell: Geo-Slip (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

function onMagicCastingCheck(caster, target, spell)
    return GEOMANCER.geoCastingCheck(caster, target, spell);
end;

function onSpellCast(caster, target, spell)
    return GEOMANCER.doGeo(caster, target, spell);
end;
