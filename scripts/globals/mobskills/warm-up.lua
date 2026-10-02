---------------------------------------------
-- Warm-Up
--
-- Description: Enhances accuracy and evasion.
-- Type: Magical (Earth)
---------------------------------------------
require("scripts/globals/monstertpmoves");
require("scripts/globals/settings");
require("scripts/globals/status");
---------------------------------------------

function onMobSkillCheck(target,mob,skill)
    -- All Mamool Ja with Warm-Up in their skill list may use it (LSB parity: returns 0 for every model).
    -- Already buffed with Warm-Up's effect: don't use it again, so the mob picks another skill.
    -- Sagelord Molaal Ja force-casts Warm-Up at each HP threshold (his flee trigger): never gate him.
    if (mob:getName() ~= 'Sagelord_Molaal_Ja' and (mob:hasStatusEffect(EFFECT_ACCURACY_BOOST) or mob:hasStatusEffect(EFFECT_EVASION_BOOST))) then
        return 1;
    end
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    -- This is nonsensically overpowering: mob:getMainLvl() + 0.05*mob:getMaxHP()*(skill:getTP()/1000);
    local power = 10; -- Power needs redone with retail MOB VERSION formula not players blue magic
    local EFFECT;
    local rand = math.random(); -- 0 to 1..
    --[[
        After checking retail this mobskill appeared to grant only
        1 of the 2 effects unlike the blue magic version
    ]]
    if (mob:hasStatusEffect(EFFECT_ACCURACY_BOOST)) then
        skill:setMsg(MobBuffMove(mob, EFFECT_EVASION_BOOST, power, 0, 180));
        EFFECT = EFFECT_EVASION_BOOST;
    elseif (mob:hasStatusEffect(EFFECT_EVASION_BOOST)) then
        skill:setMsg(MobBuffMove(mob, EFFECT_ACCURACY_BOOST, power, 0, 180));
        EFFECT = EFFECT_ACCURACY_BOOST;
    else
        if (rand < 0.5) then
            skill:setMsg(MobBuffMove(mob, EFFECT_EVASION_BOOST, power, 0, 180));
            EFFECT = EFFECT_EVASION_BOOST;
        else
            skill:setMsg(MobBuffMove(mob, EFFECT_ACCURACY_BOOST, power, 0, 180));
            EFFECT = EFFECT_ACCURACY_BOOST;
        end
    end

    return EFFECT;
end;
