---------------------------------------------
--  Accursed Armor  (Kholomodumo, Voidwatch)
--  [B #614] curse spikes. Skill id 2390, anim 1663, msg 101 [C Raguza 2021.03.28].
--  Spikes type 4 (curse) is handled by the engine (battleutils HandleSpikesStatusEffect): attacker gets Curse.
--  Duration 60 s and the curse potency are [D]; the mob script (tickArmor) removes the mods on expiry.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    if (mob:getLocalVar("ARMOR_END") > os.time()) then return 1; end -- already up
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    mob:setLocalVar("ARMOR_END", os.time() + 60);
    mob:addMod(MOD_SPIKES, 4);     -- SUBEFFECT_CURSE_SPIKES
    mob:addMod(MOD_SPIKES_DMG, 0);
    skill:setMsg(msgBasic.USES);
    return 0;
end;
