---------------------------------------------
--  Firespit
--
--  Description: Deals fire damage to an enemy.
--  Type: Magical (Fire)
---------------------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

---------------------------------------------

-- Mamool Ja Training Grounds (zone 66): Dilapidated Gates take 30% max HP per Firespit within 8' of
-- the caster (ported from Topaz firespit.lua, GATE_DMG_FRACTION 0.30).
local function splashGates(mob)
    local instance = mob:getInstance();
    if instance and mob:getZoneID() == 66 then
        for _, g in pairs(instance:getMobs()) do
            if g:getName() == "Dilapidated_Gate" and g:isAlive() and g:checkDistance(mob) <= 8 then
                local amt = math.ceil(g:getMaxHP() * 0.30);
                if amt >= g:getHP() then g:setHP(0); else g:delHP(amt); end
            end
        end
    end
end

function onMobSkillCheck(target,mob,skill)
  if(mob:getFamily() == 91) then
    local mobSkin = mob:getModelId();

    if (mobSkin == 1639) then
        return 0;
    else
        return 1;
    end
  end
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local dmgmod = 1;
    local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*4,ELE_FIRE,dmgmod,TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_FIRE,MOBPARAM_IGNORE_SHADOWS);
    target:delHP(dmg);
    splashGates(mob);
    return dmg;
end;
