-----------------------------------
-- Area: Nyzul Isle
--  Mob: Dvali Jonah (boss floor 100, Uncharted Area Survey, instance 52)
-----------------------------------
-- Reskin of the real Aydeewa Subterrane ZNM Pandemonium_Warden
-- (scripts/zones/Aydeewa_Subterrane/mobs/Pandemonium_Warden.lua) -- same familyid/modelid/full
-- stat line (mob_pools poolid 7006), same 21-phase model-swap + astral-flow-avatar fight, same
-- 16-pet array mechanic (Dvalis Ritual Lamp x16 at base+1..+16), ported to this zone's real ids
-- (IDs.lua NyzulIsle.mobs[52]). mobModelID/petModelID/skillID/avatarSkins are universal FFXI
-- model/skill ids (not Aydeewa-zone-local), so the full phase table carries over unmodified --
-- confirmed by reading the base script in full this session. Title (PANDEMONIUM_QUELLER) is a
-- real, non-zone-locked title tied to this same mob's stats/skills, kept as-is.
-----------------------------------
require("scripts/globals/nyzul")
require("scripts/globals/status")
require("scripts/globals/magic")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local BASE = NyzulIsle.mobs[52].DVALI_JONAH
local PETBASE = NyzulIsle.mobs[52].DVALI_JONAH_ADDBASE

-- Pet Arrays, alternate between phases (identical structure to base script)
local petIDs = {}
petIDs[0] = {PETBASE+1, PETBASE+2, PETBASE+3, PETBASE+4, PETBASE+5, PETBASE+6, PETBASE+7, PETBASE+8}
petIDs[1] = {PETBASE+9, PETBASE+10, PETBASE+11, PETBASE+12, PETBASE+13, PETBASE+14, PETBASE+15, PETBASE+16}

-- Phase Arrays      Dverg,  Char1, Dverg,  Char2, Dverg,  Char3, Dverg,  Char4,  Dverg,   Mamo,  Dverg,  Lamia,  Dverg,  Troll,  Dverg,   Cerb,  Dverg,  Hydra,  Dverg,   Khim,  Dverg
--                       1       2      3       4      5       6      7       8       9      10      11      12      13      14      15      16      17      18      19      20
local triggerHPP = {    95,      1,    95,      1,    95,      1,    95,      1,     95,      1,     95,      1,     95,      1,     95,      1,     95,      1,     95,      1}
local mobHP =      { 10000, 147000, 10000, 147000, 10000, 147000, 10000, 147000,  15000, 147000,  15000, 147000,  15000, 147000,  20000, 147000,  20000, 147000,  20000, 147000}
local mobModelID = {  1825,   1840,  1825,   1840,  1825,   1840,  1825,   1840,   1863,   1840,   1865,   1840,   1867,   1840,   1793,   1840,   1796,   1840,   1805,   1840}
local petModelID = {  1823,   1841,  1821,   1841,  1825,   1841,  1824,   1841,   1639,   1841,   1643,   1841,   1680,   1841,    281,   1841,    421,   1841,   1746,   1839}
local skillID =    {  1000,    316,  1001,    316,  1002,    316,  1003,    316,   1158,    316,    725,    316,    326,    316,     62,    316,    164,    316,    168,    316}

-- Avatar Arrays         Shiva, Ramuh, Titan, Ifrit, Levia, Garud, Fenri, Carby
local avatarAbilities = {  917,   918,   914,   913,   915,   916,   839,   919}
local avatarSkins =     {   22,    23,    19,    18,    20,    21,    17,    16}

function onMobSpawn(mob)
    mob:setMod(MOD_DEF, 450)
    mob:setMod(MOD_MEVA, 380)
    mob:setMod(MOD_MDEF, 50)
    mob:setModelId(1840)
    mob:setUnkillable(true)
    mob:hideHP(true)

    mob:setLocalVar("PWDespawnTime", os.time() + 7200)
    mob:setLocalVar("phase", 1)
    mob:setLocalVar("astralFlow", 1)
end

function onMobDisengage(mob)
    local instance = mob:getInstance()
    mob:setModelId(1840)
    mob:setMobMod(MOBMOD_SKILL_LIST, 316)

    mob:setUnkillable(true)
    mob:hideHP(true)

    mob:setLocalVar("phase", 1)
    mob:setLocalVar("astralFlow", 1)

    for i = 0, 1 do
        for j = 1, 8 do
            if GetMobByID(petIDs[i][j], instance):isSpawned() then
                DespawnMob(petIDs[i][j], instance)
            end
        end
    end
end

function onMobEngaged(mob, target)
    local instance = mob:getInstance()
    for i = 1, 8 do
        local pet = GetMobByID(petIDs[1][i], instance)
        pet:setModelId(1841)
        pet:spawn()
        pet:updateEnmity(target)
    end
end

local function handlePet(mob, newPet, oldPet, target, modelId, instance)
    if oldPet:isSpawned() then
        DespawnMob(oldPet:getID(), instance)
    end
    newPet:setModelId(modelId)
    newPet:spawn()
    newPet:setPos(mob:getXPos() + math.random(-2, 2), mob:getYPos(), mob:getZPos() + math.random(-2, 2))
    newPet:updateEnmity(target)
end

function onMobFight(mob, target)
    local instance = mob:getInstance()
    local mobHPP = mob:getHPP()
    local depopTime = mob:getLocalVar("PWDespawnTime")
    local phase = mob:getLocalVar("phase")
    local astral = mob:getLocalVar("astralFlow")
    local pets = {}
    for i = 0, 1 do
        pets[i] = {}
        for j = 1, 8 do
            pets[i][j] = GetMobByID(petIDs[i][j], instance)
        end
    end

    if (phase < 21 and mobHPP <= triggerHPP[phase]) then
        if (phase == 20) then
            mob:hideHP(false)
            mob:setUnkillable(false)
        end

        mob:setTP(0)
        mob:setModelId(mobModelID[phase])
        mob:setHP(mobHP[phase])
        mob:setMobMod(MOBMOD_SKILL_LIST, skillID[phase])

        for i = 1, 8 do
            local oldPet = pets[phase % 2][i]
            local newPet = pets[(phase - 1) % 2][i]
            newPet:updateEnmity(target)
            newPet:setMobMod(MOBMOD_MAGIC_DELAY, 4)
            handlePet(mob, newPet, oldPet, target, petModelID[phase], instance)
        end

        mob:setLocalVar("phase", phase + 1)

    elseif (phase == 21 and astral < 9 and mobHPP <= (100 - 25 * astral)) then
        for i = 1, 8 do
            local oldPet = pets[astral % 2][i]
            local newPet = pets[(astral - 1) % 2][i]
            if i == 1 then
                newPet:updateEnmity(target)
                local astralRand = math.random(1, 8)
                handlePet(mob, newPet, oldPet, target, avatarSkins[astralRand], instance)
                newPet:useMobAbility(avatarAbilities[astralRand])
            else
                handlePet(mob, newPet, oldPet, target, 1839, instance)
            end
        end

        mob:setLocalVar("astralFlow", astral + 1)
    end

    if (os.time() > depopTime and mob:actionQueueEmpty() == true) then
        for i = 0, 1 do
            for j = 1, 8 do
                if pets[i][j]:isSpawned() then
                    DespawnMob(petIDs[i][j], instance)
                end
            end
        end
        DespawnMob(BASE, instance)
    end
end

function onMobDeath(mob, player, isKiller)
    local instance = mob:getInstance()
    player:addTitle(PANDEMONIUM_QUELLER)

    for i = 0, 1 do
        for j = 1, 8 do
            if GetMobByID(petIDs[i][j], instance):isSpawned() then
                DespawnMob(petIDs[i][j], instance)
            end
        end
    end

    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
    Nyzul.bossArmorDrop(player, mob)
    Nyzul.unchartedJonahCoinPurseDrop(player, mob)
    Nyzul.unchartedAstrariaFragmentGain(player, mob)
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    for i = 0, 1 do
        for j = 1, 8 do
            if GetMobByID(petIDs[i][j], instance):isSpawned() then
                DespawnMob(petIDs[i][j], instance)
            end
        end
    end
end

