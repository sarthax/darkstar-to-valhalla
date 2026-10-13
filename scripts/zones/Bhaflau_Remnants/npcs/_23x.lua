-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Gateway (_23x, LSB: DOOR_5_2)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23x.lua
-- ("5th Floor Door to Boss") + its shared xi.salvage.openBossDoor helper, inlined here since it's
-- a one-off Floor-5-specific mechanic (not reused elsewhere in this zone). Opens itself for 15s
-- and, after a 3s delay, opens its paired companion door (_23w, this id minus 1 -- same real
-- "twin door leaves" pattern already documented elsewhere in this codebase) for 10s.
--
-- Ported as-is: LSB's own real onTrigger has no unSealed/sealed-message check at all for this
-- specific door (unlike every other door in this zone) -- not adding one that isn't in the real
-- source.
-----------------------------------
function onTrigger(player, npc)
    if npc:getAnimation() == ANIMATION_CLOSE_DOOR then
        local instance = npc:getInstance()

        npc:openDoor(15)
        npc:queue(3000, function(npcArg)
            local companion = GetNPCByID(npcArg:getID() - 1, instance)
            if companion then
                companion:openDoor(10)
            end
        end)
    end
end

