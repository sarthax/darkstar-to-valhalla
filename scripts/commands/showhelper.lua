require("scripts/globals/status")
-----------------------------------
-- func: showhelper <npcid> [modelid]
-- desc: GM diagnostic tool -- added 2026-08-24 to visually verify whether a "helper" prop entity
--       (door/terrain-unlock trigger, e.g. the _1ub/_1u5-class props) is really sitting where its
--       SQL data claims. Several of these were found offset from real capture data this session
--       (see the door-prop-pairing/1x-prop-blocker memory entries) -- this makes that kind of
--       drift visible in-game instead of having to reason about it purely from coordinates.
--
-- What it does:
--   1. Looks up the entity by id (instance-scoped if you're currently inside one, zone-wide
--      otherwise) and prints its real live x/y/z/rot.
--   2. Clears untargetable (CNpcEntity::Untargetable(false) -- confirmed working via this
--      session's earlier Saving Private Ryaaf fix) so you can /target it and read its name/
--      distance/facing off the target bar as a second confirmation.
--   3. Warps you directly onto its coordinates, so if the model itself is too small/plain to spot
--      by eye you can still tell "something is/isn't here" just by standing on top of it.
--   4. Optionally swaps its model to whatever modelid you pass (see !setmobmodel for how to find
--      one) if the default prop model is too subtle to see against the terrain -- purely visual,
--      does not touch entityFlags/collision.
--
-- This does NOT persist -- untargetable/model changes only last until the entity next reloads
-- (zone reset, instance teardown, or a repop). It never touches SQL.
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = "is"
}

function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!showhelper {npcid} [modelid]")
end

function onTrigger(player, npcid, modelidArg)
    if npcid == nil then
        error(player, "You must provide an npc id.")
        return
    end

    local instance = player:getInstance()
    local npc = instance and instance:getEntity(bit.band(npcid, 0xFFF), TYPE_NPC) or GetNPCByID(npcid)

    if npc == nil then
        player:PrintToPlayer(string.format("No entity with id %u found (instance-scoped: %s).",
            npcid, tostring(instance ~= nil)))
        return
    end

    local x, y, z, rot = npc:getXPos(), npc:getYPos(), npc:getZPos(), npc:getRotPos()
    player:PrintToPlayer(string.format("%s (%u) real live position: %.3f, %.3f, %.3f, rot %u",
        npc:getName(), npcid, x, y, z, rot))

    npc:untargetable(false)
    player:PrintToPlayer("untargetable cleared -- /target it to confirm name/distance.")

    local modelid = tonumber(modelidArg)
    if modelid then
        npc:setModelId(modelid)
        player:PrintToPlayer(string.format("model swapped to %u (visual only, reverts on reload).", modelid))
    end

    player:setPos(x, y, z, rot)
    player:PrintToPlayer("Warped you onto its exact coordinates.")
end
