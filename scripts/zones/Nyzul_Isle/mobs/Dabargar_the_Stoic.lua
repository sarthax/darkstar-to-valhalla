-----------------------------------
-- Area: Nyzul Isle
--  Mob: Dabargar the Stoic (boss floor 20/40/60, Uncharted Area Survey, instance 52)
-----------------------------------
-- Reskin of the real Halvung HNM Gurfurlur_the_Menacing
-- (scripts/zones/Halvung/mobs/Gurfurlur_the_Menacing.lua) -- same familyid/modelid/full stat
-- line (mob_pools poolid 7001), same escort-add mechanic (Hilltroll Honor Guard x2 / Woodtroll
-- Honor Guard x2 at base+1..+4), ported to this zone's real ids (IDs.lua NyzulIsle.mobs[52]). The
-- Halvung-specific title award (TROLL_SUBJUGATOR) is dropped -- no equivalent exists, not invented.
-----------------------------------
require("scripts/globals/nyzul")
require("scripts/globals/status")
mixins = {require("scripts/mixins/job_special")}
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local BASE = NyzulIsle.mobs[52].DABARGAR_THE_STOIC_ADDBASE

function onMobEngaged(mob, target)
    local instance = mob:getInstance()
    for i = BASE + 1, BASE + 4 do
        SpawnMob(i, instance):updateEnmity(target)
    end
end

function onMobFight(mob, target)
    local instance = mob:getInstance()
    if mob:getBattleTime() % 60 < 2 and mob:getBattleTime() > 10 then
        if not GetMobByID(BASE + 1, instance):isSpawned() then
            GetMobByID(BASE + 1, instance):setSpawn(mob:getXPos()+math.random(1, 5), mob:getYPos(), mob:getZPos()+math.random(1, 5))
            SpawnMob(BASE + 1, instance):updateEnmity(target)
        elseif not GetMobByID(BASE + 2, instance):isSpawned() then
            GetMobByID(BASE + 2, instance):setSpawn(mob:getXPos()+math.random(1, 5), mob:getYPos(), mob:getZPos()+math.random(1, 5))
            SpawnMob(BASE + 2, instance):updateEnmity(target)
        elseif not GetMobByID(BASE + 3, instance):isSpawned() then
            GetMobByID(BASE + 3, instance):setSpawn(mob:getXPos()+math.random(1, 5), mob:getYPos(), mob:getZPos()+math.random(1, 5))
            SpawnMob(BASE + 3, instance):updateEnmity(target)
        elseif not GetMobByID(BASE + 4, instance):isSpawned() then
            GetMobByID(BASE + 4, instance):setSpawn(mob:getXPos()+math.random(1, 5), mob:getYPos(), mob:getZPos()+math.random(1, 5))
            SpawnMob(BASE + 4, instance):updateEnmity(target)
        end
    end

    for i = BASE + 1, BASE + 4 do
        local pet = GetMobByID(i, instance)
        if pet:getCurrentAction() == ACTION_ROAMING then
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

