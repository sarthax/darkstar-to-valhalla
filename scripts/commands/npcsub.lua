-----------------------------------
-- func: npcsub
-- desc: Changes the sub-animation of the given npc. (For testing purposes.)
-----------------------------------
-- 2026-09-01: mobsub.lua's own NPC-side counterpart -- mobsub only ever looks up TYPE_MOB targets
-- (targ:isMob() gate, GetMobByID()), so it can't reach any TYPE_NPC entity (e.g. Bridge_Switch).
-- setAnimationSub() itself is fully generic (lua_baseentity.cpp), the restriction was purely
-- mobsub's own target lookup -- this mirrors its structure, swapped to GetNPCByID/isNPC().
-- Explicit-id lookup checks the player's own instance first, same proven pattern as
-- setmobmodel.lua -- most things worth testing this way (e.g. Bridge_Switch) are instance-scoped,
-- and a plain global-only GetNPCByID() (mobsub's own explicit-id path never instance-scopes
-- either) would return nil for those, same root-cause class as the GetMobByID-missing-instance-
-- arg bug already found and fixed for Excaliace/the win-condition check this session.
-----------------------------------

require("scripts/globals/status")

cmdprops =
{
    permission = 1,
    parameters = "ss"
}

function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!npcsub {npc ID} <animation ID>")
end

function onTrigger(player, arg1, arg2)
    local target
    local animationId

    if (arg2 ~= nil) then
        target = arg1
        animationId = arg2
    elseif (arg1 ~= nil) then
        animationId = arg1
    else
        error(player, "You must provide an animation ID.")
        return
    end

    -- validate target
    local targ
    if (target == nil) then
        targ = player:getCursorTarget()
        if (targ == nil or not targ:isNPC()) then
            error(player, "You must either provide an npc ID or target an npc.")
            return
        end
    else
        local npcid = tonumber(target)
        local instance = player:getInstance()
        if (instance) then
            targ = instance:getEntity(bit.band(npcid, 0xFFF), TYPE_NPC)
        end
        if (not targ) then
            targ = GetNPCByID(npcid)
        end
        if (targ == nil) then
            error(player, "Invalid npc ID.")
            return
        end
    end

    -- validate animationId
    animationId = tonumber(animationId) or xi.anim[string.upper(animationId)]
    if (animationId == nil or animationId < 0) then
        error(player, "Invalid animation ID.")
        return
    end

    -- set animation sub
    targ:AnimationSub( animationId )
    -- 2026-09-02: without this, a plain animationsub-only update packet doesn't reliably force
    -- the client to redraw an entity that's already been spawned/rendering for a while -- the
    -- exact issue found live on Switch.lua/Bridge_Switch.lua, which needed forceRespawn() to
    -- actually show the change. Added here too so live !npcsub testing gives a true read on
    -- whether a given value actually looks different, not a false negative from stale rendering.
    targ:forceRespawn()
end
