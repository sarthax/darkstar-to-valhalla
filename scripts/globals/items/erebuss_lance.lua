-----------------------------------------
-- ID: 19315
-- Item: Erebus's Lance
-- Additional Effect vs. Empty: damage varies with current TP
-- Source: user-supplied wiki notes -- activates on ~5% of melee hits (Enlight animation = light damage),
--         damage = current TP / 14 (about 9-70 below 1000 TP, about 194-210 at 3000 TP).
-- ASSUMPTION: no resistance/MAB adjustment is applied (the formula is a flat TP/14).
-----------------------------------------
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");

-----------------------------------
-- onAdditionalEffect Action
-----------------------------------

function onAdditionalEffect(player,target,damage)
    if (target:getSystem() ~= SYSTEM_EMPTY or math.random(0,99) >= 5) then
        return 0,0,0;
    end

    local dmg = math.floor(player:getTP() / 14);
    if (dmg <= 0) then
        return 0,0,0;
    end

    return SUBEFFECT_LIGHT_DAMAGE, msgBasic.ADD_EFFECT_DMG, dmg;
end;
