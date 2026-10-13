-----------------------------------
-- Area: Nyzul Isle
--  Mob: Stealthlord Haraal Ja (boss floor 20/40/60, Uncharted Area Survey, instance 52)
-----------------------------------
-- Reskin of the real Mamook HNM Gulool_Ja_Ja (scripts/zones/Mamook/mobs/Gulool_Ja_Ja.lua) --
-- same familyid/modelid/full stat line (mob_pools poolid 6998), same escort-add mechanic
-- (Ja Chamberlain Escort x2 / Ja Palatine Escort x2 at base+1..+4), ported to this zone's real
-- ids (see IDs.lua NyzulIsle.mobs[52]). The Mamook-specific title award (SHINING_SCALE_RIFLER) is
-- dropped -- no equivalent Nyzul title exists, not invented here.
-----------------------------------
require("scripts/globals/nyzul")
require("scripts/globals/status")
require("scripts/zones/Nyzul_Isle/IDs")
mixins = {require("scripts/mixins/job_special")}
-----------------------------------
local BASE = NyzulIsle.mobs[52].STEALTHLORD_HARAAL_JA_ADDBASE

function onMobSpawn(mob)
    mob:setMod(MOD_DOUBLE_ATTACK, 20)
    mob:setMobMod(MOBMOD_DRAW_IN, 2)
end

function onMobEngaged(mob, target)
    local instance = mob:getInstance()
    for i = BASE + 1, BASE + 4 do
        SpawnMob(i, instance):updateEnmity(target)
    end
end

function onMobFight(mob, target)
    local instance = mob:getInstance()
    if (mob:getBattleTime() % 60 < 2 and mob:getBattleTime() > 10) then
        if (not GetMobByID(BASE + 1, instance):isSpawned()) then
            GetMobByID(BASE + 1, instance):setSpawn(mob:getXPos()+math.random(1, 5), mob:getYPos(), mob:getZPos()+math.random(1, 5))
            SpawnMob(BASE + 1, instance):updateEnmity(target)
        elseif (not GetMobByID(BASE + 2, instance):isSpawned()) then
            GetMobByID(BASE + 2, instance):setSpawn(mob:getXPos()+math.random(1, 5), mob:getYPos(), mob:getZPos()+math.random(1, 5))
            SpawnMob(BASE + 2, instance):updateEnmity(target)
        elseif (not GetMobByID(BASE + 3, instance):isSpawned()) then
            GetMobByID(BASE + 3, instance):setSpawn(mob:getXPos()+math.random(1, 5), mob:getYPos(), mob:getZPos()+math.random(1, 5))
            SpawnMob(BASE + 3, instance):updateEnmity(target)
        elseif (not GetMobByID(BASE + 4, instance):isSpawned()) then
            GetMobByID(BASE + 4, instance):setSpawn(mob:getXPos()+math.random(1, 5), mob:getYPos(), mob:getZPos()+math.random(1, 5))
            SpawnMob(BASE + 4, instance):updateEnmity(target)
        end
    end
    for i = BASE + 1, BASE + 4 do
        local pet = GetMobByID(i, instance)
        if (pet:getCurrentAction() == ACTION_ROAMING) then
            pet:updateEnmity(target)
        end
    end
end

function onMobDisengage(mob)
    local instance = mob:getInstance()
    for i = 1, 4 do DespawnMob(BASE + i, instance) end
end

function onMobDeath(mob, player, isKiller)
    local instance = mob:getInstance()
    for i = 1, 4 do DespawnMob(BASE + i, instance) end
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
    Nyzul.bossArmorDrop(player, mob)
    Nyzul.unchartedTierBossCoinPurseDrop(player, mob)
    Nyzul.unchartedAstrariaFragmentGain(player, mob)
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    for i = 1, 4 do DespawnMob(BASE + i, instance) end
end

