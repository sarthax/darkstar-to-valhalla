-----------------------------------------
--    Spell: Foil
-----------------------------------------

require("scripts/globals/status");
require("scripts/globals/magic");

function onMagicCastingCheck(caster,target,spell)
    return 0;
end;

function onSpellCast(caster,target,spell)
    local duration = 30;
    if (caster:hasStatusEffect(EFFECT_COMPOSURE) == true and caster:getID() == target:getID()) then
        duration = duration * 3;
    end

    if (target:addStatusEffect(EFFECT_FOIL,150,3,duration)) then
        spell:setMsg(230);
    else
        spell:setMsg(75);
    end

    return EFFECT_FOIL;
end;
