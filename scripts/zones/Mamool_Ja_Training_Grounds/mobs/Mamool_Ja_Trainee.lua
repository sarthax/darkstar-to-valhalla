-----------------------------------
-- Area: Mamool Ja Training Grounds
--  Mob: Mamool Ja Trainee
-----------------------------------
-- 2026-09-19: BST-job Trainees (poolname Mamool_Ja_Trainee_bst) now have their Lizard pet.
-- Root cause of "BST mobs have no pets": instance_loader.cpp has "//TODO: pets" (mob_pets is only
-- attached at boot for persistent zone mobs) and neither DSP nor Topaz has a mob_pets row for zone
-- 66. Same manual-link approach as Topaz's Arrapago_Remnants/Reserve_Draugar.lua: the pet is
-- enmity-linked to its master on engage and kept near it during the fight. Pairing (master id ->
-- Lizard id) is INFERRED from spawn-id order -- see instances/sagelord_elimination.lua.
-- Non-BST Trainees (nin/blu) have no entry here and are unaffected.
-----------------------------------
local BST_PETS = {
    [17047592] = 17047593, [17047594] = 17047596, [17047602] = 17047604,
    [17047606] = 17047607, [17047608] = 17047609,
}

local function getPet(mob)
    local petId = BST_PETS[mob:getID()]
    if petId then
        return mob:getInstance():getEntity(bit.band(petId, 0xFFF), TYPE_MOB)
    end
end

function onMobEngaged(mob, target)
    local pet = getPet(mob)
    if pet and pet:isAlive() then
        pet:updateEnmity(target)
    end
end

function onMobFight(mob, target)
    local pet = getPet(mob)
    if pet and pet:isAlive() then
        pet:updateEnmity(target)
        if math.abs(mob:getXPos() - pet:getXPos()) > 15 or math.abs(mob:getZPos() - pet:getZPos()) > 15 then
            pet:setPos(mob:getXPos(), mob:getYPos(), mob:getZPos(), mob:getRotPos())
        end
    end
end

function onMobDeath(mob, player, isKiller)
end
