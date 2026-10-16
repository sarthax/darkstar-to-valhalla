-----------------------------------
-- Ability: Concentric Pulse (slice run-geo-jobs)
-- Luopan detonates on the target for damage equal to its current HP, then vanishes.
-- Implemented as a player ability (DSP has no pet_skills table).
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

GEOMANCER.CONCENTRIC_RANGE = 10; -- yalms, luopan to target
-- Bagua Galero +2/+3/+4 (item_basic ids): damage uses the luopan's max HP instead of current HP
GEOMANCER.CONCENTRIC_MAXHP_HEADS = { [23083] = true, [23418] = true, [23938] = true };

function onAbilityCheck(player,target,ability)
    local luopan = GEOMANCER.getLuopan(player);
    if (luopan == nil) then
        return GEOMANCER.MSG_UNABLE_JA, 0;
    end
    if (luopan:checkDistance(target) > GEOMANCER.CONCENTRIC_RANGE) then
        return GEOMANCER.MSG_UNABLE_JA, 0;
    end
    return 0, 0;
end;

function onUseAbility(player,target,ability)
    ability:setMsg(110);
    local luopan = GEOMANCER.getLuopan(player);
    if (luopan == nil) then return 0; end
    local dmg = luopan:getHP();
    if (GEOMANCER.CONCENTRIC_MAXHP_HEADS[player:getEquipID(SLOT_HEAD)]) then
        dmg = luopan:getMaxHP();
    end
    -- job point damage bonus: getJobPointLevel is a stub in DSP (returns 0); live when Valhalla provides it
    local jp = player:getJobPointLevel(JP_CONCENTRIC_PULSE_EFFECT or 0) or 0;
    dmg = dmg + math.floor(dmg * jp / 100);
    target:delHP(dmg);
    player:despawnPet();
    return dmg;
end;
