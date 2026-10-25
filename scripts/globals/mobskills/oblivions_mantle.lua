---------------------------------------------
--  Oblivion's Mantle  (Ig-Alima, Voidwatch)
--  [C] anim 1962; AoE Weakness (1 min) + 10-count Doom, used right after Diluvial Wake [F]. Amounts [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    if (mob:getLocalVar("VW_DEADLINE") == 0) then return 1; end -- Voidwatch-only: base mobs sharing this skill stay inert (no Lua existed before VW)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    MobStatusEffectMove(mob, target, EFFECT_WEAKNESS, 1, 0, 60);
    skill:setMsg(MobStatusEffectMove(mob, target, EFFECT_DOOM, 10, 3, 30));
    return EFFECT_DOOM;
end;
