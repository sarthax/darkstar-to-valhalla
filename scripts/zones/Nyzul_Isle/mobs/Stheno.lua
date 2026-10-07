-----------------------------------
-- Area: Nyzul Isle
--  Mob: Stheno (boss floor 60, Uncharted Area Survey, instance 52)
-----------------------------------
-- Reskin of the real Arrapago Reef NM Medusa (scripts/zones/Arrapago_Reef/mobs/Medusa.lua) --
-- same familyid/modelid/full stat line (mob_pools poolid 7004), same job-special Eagle Eye Shot
-- config, same escort-add mechanic (Sthenos Gorgon Handmaid x4 at base+1..+4), ported to this
-- zone's real ids (IDs.lua NyzulIsle.mobs[52]). The Arrapago-specific engage/death showText and title
-- (GORGONSTONE_SUNDERER) are dropped -- their text ids are zone-local and unverified for Nyzul,
-- not invented here.
-----------------------------------
require("scripts/globals/nyzul")
require("scripts/globals/status")
mixins = {require("scripts/mixins/job_special")}
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local BASE = NyzulIsle.mobs[52].STHENO_ADDBASE

function onMobSpawn(mob)
    -- DSP port: Topaz's tpz.mix.jobSpecial (chance 75, EES_LAMIA) does not exist in DSP; replaced with
    -- the same localvar pattern DSP's own Arrapago_Reef Medusa.lua uses (ability 1931 = Eagle Eye Shot).
    -- 75% chance to use it at all ("possible she will not use Eagle Eye Shot at all").
    mob:setLocalVar("usedees", 0)
    if math.random(1, 100) <= 75 then
        mob:setLocalVar("eeshpp", math.random(5, 99))
    else
        mob:setLocalVar("eeshpp", 0)
    end
end

function onMobEngaged(mob, target)
    local instance = mob:getInstance()
    for i = BASE + 1, BASE + 4 do
        SpawnMob(i, instance):updateEnmity(target)
    end
end

function onMobFight(mob, target)
    local instance = mob:getInstance()
    if mob:getLocalVar("usedees") == 0 and mob:getLocalVar("eeshpp") > 0 and mob:getHPP() <= mob:getLocalVar("eeshpp") then
        mob:useMobAbility(1931) -- Eagle Eye Shot
        mob:setLocalVar("usedees", 1)
    end
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

