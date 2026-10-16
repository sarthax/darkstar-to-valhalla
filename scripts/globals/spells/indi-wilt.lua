-----------------------------------
-- Spell: Indi-Wilt (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

function onMagicCastingCheck(caster, target, spell)
    return GEOMANCER.indiCastingCheck(caster, target, spell);
end;

function onSpellCast(caster, target, spell)
    return GEOMANCER.doIndi(caster, target, spell);
end;
