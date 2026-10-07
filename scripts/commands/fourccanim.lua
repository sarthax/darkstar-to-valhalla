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

    local id = tonumber(arg1)
    if (arg2 == nil or arg2 == "" or id == nil) then
        -- no (numeric) npcId given. Use cursor target; arg1 is the code (if arg1 isn't a number
        -- but arg2 is present, e.g. the code was split by a space, join them back together).
        targ = player:getCursorTarget()
        code = arg1
        if (arg2 ~= nil and arg2 ~= "" and id == nil) then
            code = arg1 .. arg2
        end
    else
        -- instance entities need the instance passed to the lookup
        local inst = player:getInstance()
        targ = GetNPCByID(id, inst) or GetMobByID(id, inst) or GetNPCByID(id) or GetMobByID(id)
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

    -- the command parser strips trailing/quoted spaces, so: "_" stands for a space, and a code
    -- shorter than 4 characters is right-padded with spaces (e.g. "bow" or "bow_" -> "bow ")
    if (code ~= nil) then
        code = string.gsub(code, "_", " ")
        if (string.len(code) < 4) then
            code = code .. string.rep(" ", 4 - string.len(code))
        end
    end
    if (code == nil or string.len(code) ~= 4) then
        error(player, "Code must be 4 characters or fewer (padded with spaces; \"_\" = space, e.g. \"DC0\" -> \"DC0 \").")
        return
    end

    targ:entityAnimationPacket(code)
    player:PrintToPlayer(string.format("Entity ID: %i - %s (%s) | Sent FourCC animation code: \"%s\"\n",
        targ:getID(), targ:getName(), targ:isMob() and "mob" or "npc", code))
end
