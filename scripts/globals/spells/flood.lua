-----------------------------------------
-- Spell: Flood
-- Deals water damage to an enemy and lowers its resistance against lightning.
-----------------------------------------

require("scripts/globals/magic");
require("scripts/globals/status");

-----------------------------------------
-- OnSpellCast
-----------------------------------------

function onMagicCastingCheck(caster, target, spell)
    return 0;
end;

function onSpellCast(caster, target, spell)
    local spellParams = {};
    spellParams.hasMultipleTargetReduction = false;
    spellParams.resistBonus = 1.0;
    spellParams.V0 = 700;
    spellParams.V50 = 800;
    spellParams.V100 = 900;
    spellParams.V200 = 1100;
    spellParams.M0 = 2;
    spellParams.M50 = 2;
    spellParams.M100 = 2;
    spellParams.M200 = 2;

    local dmg = doElementalNuke(caster, spell, target, spellParams);

    -- Krabimanjaro (Voidwatch): crab NMs that cast Flood also have an AoE "Floodga" variant that DSP lacks;
    -- emulate it here by splashing alliance members near the target (same local-override idea as the
    -- Mamool Ja Firespit splash). Name-guarded so no other caster is affected. Radius 10' is a [D] guess.
    if (caster:isMob() and caster:getName() == "Krabimanjaro" and target:isPC()) then
        for _, m in pairs(target:getAlliance()) do
            if (m:getID() ~= target:getID() and m:isAlive() and m:getZoneID() == target:getZoneID()
                and m:checkDistance(target) <= 10) then
                m:delHP(doElementalNuke(caster, spell, m, spellParams));
            end
        end
    end
    return dmg;
end;
