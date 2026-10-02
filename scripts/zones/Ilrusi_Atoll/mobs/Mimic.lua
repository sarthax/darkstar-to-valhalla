-----------------------------------
-- Area: Ilrusi Atoll (Golden Salvage)
--  Mob: Mimic (a revealed Cursed Chest)
-----------------------------------
-- Cursed_Chest.lua's onTrigger calls setName("Mimic"); in DSP setName() overwrites the entity's
-- real name (unlike Topaz), so from then on luautils looks for mobs/Mimic.lua. Without this file
-- the revealed chest never ran its Draw In. Logic is the same as Topaz's Cursed_Chest onMobFight.
-----------------------------------
require("scripts/globals/status")
-----------------------------------
local function CheckForDrawnIn(centerX, centerY, centerZ, playerX, playerY, playerZ, Rayon, maxRayon)
    local difX = playerX - centerX
    local difY = playerY - centerY
    local difZ = playerZ - centerZ
    local Distance = math.sqrt(difX * difX + difY * difY + difZ * difZ)
    return Distance > Rayon and Distance < maxRayon
end

function onMobFight(mob, target)
    if CheckForDrawnIn(mob:getXPos(), mob:getYPos(), mob:getZPos(), target:getXPos(), target:getYPos(), target:getZPos(), 3, 22) then
        target:setPos(mob:getXPos(), mob:getYPos(), mob:getZPos())
    end
end

function onMobDeath(mob, player, optParams)
end
