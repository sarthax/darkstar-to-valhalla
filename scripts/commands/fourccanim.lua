-----------------------------------
-- func: fourccanim
-- desc: Fires a raw CEntityAnimationPacket (0x038) FourCC animation code at an NPC or mob. For
--       testing purposes -- brute-forcing candidate 4-character motion codes (e.g. "bow ", "stgr")
--       since no server-side lookup table exists for them anywhere in this codebase (confirmed
--       2026-08-25 -- see Assault_Issue_Tracker.md's Lebros Supplies entry). The server does zero
--       validation of this string (see packets/entity_animation.cpp's memcpy) -- whatever is
--       typed here is sent verbatim, so a real code shows the expected animation and a fake one
--       just does nothing visible. Completely safe: no combat/instance-state side effects.
-- 2026-08-27: loosened the target-type check (was NPC-only) -- needed to test a real hypothesis
-- that this client build may only render FourCC entity animations for TYPE_MOB, silently no-oping
-- them for TYPE_NPC (matches a real, reproducible symptom: NPC-type users of this same Lua call
-- -- Brujeel, Pot Hatch, Ancient Lockbox -- show no confirmed working animation anywhere in this
-- codebase, while every TYPE_MOB user, e.g. Black_Baron.lua, looks like mature, live-tested
-- content). Now accepts any targetable entity (NPC or mob) so the two can be A/B tested with the
-- same code via this one command.
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = "ss"
}

function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!fourccanim {npcID} <4-char code>")
end

function onTrigger(player, arg1, arg2)
    local targ
    local code

    if (arg2 == nil) then
        -- player did not provide npcId. Shift arguments by one, use cursor target.
        targ = player:getCursorTarget()
        code = arg1
    else
        targ = GetNPCByID(tonumber(arg1)) or GetMobByID(tonumber(arg1), player:getInstance())
        code = arg2
    end

    if (targ == nil) then
        error(player, "You must either enter a valid npcID/mobID or target an NPC/mob.")
        return
    end
    if (not targ:isNPC() and not targ:isMob()) then
        error(player, "Targeted entity is not an NPC or mob.")
        return
    end

    if (code == nil or string.len(code) ~= 4) then
        error(player, "Code must be exactly 4 characters (pad with spaces if needed, e.g. \"bow \").")
        return
    end

    targ:entityAnimationPacket(code)
    player:PrintToPlayer(string.format("Entity ID: %i - %s (%s) | Sent FourCC animation code: \"%s\"\n",
        targ:getID(), targ:getName(), targ:isMob() and "mob" or "npc", code))
end
