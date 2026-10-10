-----------------------------------
-- Salvage: Arrapago Remnants
-----------------------------------
require("scripts/globals/instance")
require("scripts/zones/Arrapago_Remnants/IDs")
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(Arrapago.text.TIME_TO_COMPLETE, instance:getTimeLimit())
    player:messageSpecial(Arrapago.text.SALVAGE_START, 1)
    -- 2026-09-04: real fix -- these were all applied with duration=0 (permanent, no natural
    -- expiry), which is why they never wore off through !wa leave, !zone, or any other exit path.
    -- LSB's own real entry function applies the identical 5 effects with a real finite duration
    -- of 6000 seconds (100 minutes, matching Salvage's own real time limit) -- the intended design
    -- is a normal timed debuff that expires on its own after the instance's time limit, not
    -- something that needs an explicit removal call on every possible exit path.
    -- 2026-09-05: confirmed unrelated to the entry-time Nyzul menu mystery (live-tested with
    -- Pathos fully disabled, menu still appeared) -- re-enabled.
    player:addStatusEffectEx(EFFECT_ENCUMBRANCE_I, EFFECT_ENCUMBRANCE_I, 0xFFFF, 0, 6000)
    player:addStatusEffectEx(EFFECT_OBLIVISCENCE, EFFECT_OBLIVISCENCE, 0, 0, 6000)
    player:addStatusEffectEx(EFFECT_OMERTA, EFFECT_OMERTA, 0, 0, 6000)
    player:addStatusEffectEx(EFFECT_IMPAIRMENT, EFFECT_IMPAIRMENT, 0, 0, 6000)
    player:addStatusEffectEx(EFFECT_DEBILITATION, EFFECT_DEBILITATION, 0x1FF, 0, 6000)
    for i = 0, 15 do
        player:unequipItem(i)
    end
end

function onInstanceCreated(instance)

    for i, v in pairs(Arrapago.npcs[1][1]) do
        local npc = instance:getEntity(bit.band(v, 0xFFF), TYPE_NPC)
        npc:setStatus(STATUS_NORMAL)
    end
    instance:setStage(1)
    instance:setProgress(0)
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, Arrapago.text)
end

function onInstanceFailure(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(Arrapago.text.MISSION_FAILED, 10, 10)
        -- 2026-09-07: real fix -- was startEvent(1, 0, 0, 0, 0, 0, 0, 0, 0, 0), the same 10-arg
        -- zero-padded form already confirmed WRONG for this zone's csid 199-210 door events (see
        -- the 2026-09-04 comment on onRegionEnter below: CEventPacket bakes the real param count
        -- into the packet, and padding a call the client doesn't expect produces a param-count
        -- mismatch it can't parse -- the event fires server-side but the client never replies,
        -- so nothing visibly happens). That fix reverted the door events to a bare call, matching
        -- this zone's one confirmed-working precedent (_220.lua's startEvent(300)), but csid==1
        -- (mission timeout) was never revisited -- real user report 2026-09-07: "countdown hits 0
        -- and nothing happens," consistent with the exact same client-parse failure. Reverted to
        -- bare, same as the door events.
        v:startEvent(1)
    end
end

function onInstanceComplete(instance)
end

function onRegionEnter(player, region, instance)
    -- 2026-09-04: TEMP DEBUG (telepad investigation) -- remove once resolved
    -- print(string.format("[TELEPAD DEBUG] onRegionEnter: player=%s regionID=%d csid=%d",
          -- player:getName(), region:GetRegionID(), 199 + region:GetRegionID()))
    -- 2026-09-06: REVERTED -- region 13 (the second symmetric telepad) really did send the player
    -- back to floor 2 (csid 212's real baked-in destination), but user confirmed live-testing this
    -- is a dead end: floor doors seal shut permanently once the instance advances stage, so a
    -- player using this telepad after progressing would get permanently stuck with no way forward
    -- or back. Changed to fire the same real full exit (csid 211) as region 12, instead of csid
    -- 212 -- both telepads just exit the instance now, matching what region 14 (the old "Weather"
    -- spot convenience trigger) already does.
    if region:GetRegionID() == 13 or region:GetRegionID() == 14 then
        player:startEvent(211)
        return
    end

    if region:GetRegionID() <= 12 then
        -- 2026-09-04: REVISED -- the real crash here was the C++ "instance"/"instances" typo in
        -- luautils::OnRegionEnter (fixed separately in luautils.cpp), not the bare call itself.
        -- Padding this to 10 args (csid + 9 zeros) was speculative, borrowed from an unrelated
        -- Whitegate csid that needed it -- but CEventPacket bakes the real param count into the
        -- packet, and this zone's own confirmed-working door event (_220.lua's `startEvent(300)`,
        -- csid 300, same "Gilded Doors" event family) calls bare with zero params. Debug tracing
        -- this session showed onRegionEnter firing correctly (csid 203 confirmed) but the client
        -- never sending back ANY reply afterward -- unlike a real Runic Portal event (csid 408)
        -- that round-tripped fine the same session -- consistent with the padded call producing a
        -- param-count mismatch the client can't parse for this specific event. Reverted to bare,
        -- matching the one confirmed-working precedent in this exact zone.
        player:startEvent(199 + region:GetRegionID())
    end
end

function onInstanceProgressUpdate(instance, progress, elapsed)
    if instance:getStage() == 1 and progress == 10 then
        SpawnMob(Arrapago.mobs[1][2].rampart, instance)
    elseif instance:getStage() == 2 and progress == 2 then -- attempt to spawn slot
        instance:getEntity(bit.band(Arrapago.npcs[2][2].SLOT, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    elseif instance:getStage() == 2 and progress == 3 then -- attempt to spawn socket
        instance:getEntity(bit.band(Arrapago.npcs[2][2].SOCKET, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    elseif instance:getStage() == 3 and progress == 1 then
        SpawnMob(Arrapago.mobs[2][0].astrologer, instance)
    -- 2026-09-05: real fix -- this branch was dead code. Stage 6 is entered via _22d.lua or
    -- _22e.lua, both of which call instance:setProgress(2) or (3) immediately -- progress is never
    -- exactly 1 at that point, so the 7-minute Qiqirn Treasure Hunter timer below was never
    -- actually started (door:getLocalVar("start") stayed at its default of 0 forever, making the
    -- elapsed-time check always fail). The "start" timer is now set directly in _22d.lua/_22e.lua's
    -- own onEventFinish, right when stage 6 begins.
    elseif instance:getStage() == 6 and progress == 11 then
        -- 2026-09-05: real fix -- per confirmed real mechanic (ffxiclopedia), the west rampart
        -- (side room) only pops once the main room is fully cleared. Moved here (fires the moment
        -- progress reaches the main-room-clear threshold) instead of _22f.lua's onEventFinish,
        -- which required the player to have already walked up and used that specific door.
        SpawnMob(Arrapago.mobs[6].rampart3, instance)
    elseif instance:getStage() == 7 and progress == 0 then
        local door = instance:getEntity(bit.band(Arrapago.npcs[6].DOOR, 0xFFF), TYPE_NPC)
        door:setLocalVar("current", os.time())
        if (door:getLocalVar("current") - door:getLocalVar("start") <= 420) then
            SpawnMob(Arrapago.mobs[6].treasure_hunter1, instance)
            SpawnMob(Arrapago.mobs[6].treasure_hunter2, instance)
            SpawnMob(Arrapago.mobs[6].qiqirn_mine_1, instance)
            SpawnMob(Arrapago.mobs[6].qiqirn_mine_2, instance)
        end
    end

end

function onEventUpdate(player, csid, option)
    -- 2026-09-04: TEMP DEBUG (telepad investigation) -- remove once resolved
    -- print(string.format("[TELEPAD DEBUG] onEventUpdate: player=%s csid=%d option=%s",
          -- player:getName(), csid, tostring(option)))
end

-- 2026-09-04: real fix -- this is the actual player-facing floor-teleport/restore logic, moved
-- here from Zone.lua's own onEventFinish. luautils::LoadEventScript resolves the INSTANCE script's
-- onEventFinish before ever falling back to Zone.lua's, and OnRegionEnter always sets
-- PChar->m_event.Script to this instance file -- so Zone.lua's csid 200-210 handler was
-- unreachable dead code the entire time a player was inside this instance (confirmed via a real
-- server crash + debugger trace this session: nothing after the confirm dialog ever teleported
-- the party). Also fixes a real bug carried over from Zone.lua's version: `pos` was referenced but
-- never defined in that scope (would have errored the moment this ever actually ran) -- replaced
-- with `player:getPos()`, and the bare `startEvent(3)` call padded to the established real
-- 10-argument convention.
-- 2026-09-05: real fix -- the Pathos debuffs (afterInstanceRegister) are scoped to this zone and
-- are not supposed to persist once you actually leave it, whether by dying (mission failure) or
-- completing the run -- confirmed as the correct real mechanic by the user directly, overriding
-- LSB's own reference (which doesn't strip them either -- checked, and that looks like an
-- omission there rather than the correct design). The 6000-second real duration fixed earlier
-- still matters as a safety net (e.g. a GM !wa leave bypass that doesn't go through either real
-- exit path below), but a normal exit should clear them immediately rather than making the player
-- wait out whatever time was left.
local function stripPathos(instance)
    local chars = instance:getChars()
    for i, v in pairs(chars) do
        v:delStatusEffectSilent(EFFECT_ENCUMBRANCE_I)
        v:delStatusEffectSilent(EFFECT_OBLIVISCENCE)
        v:delStatusEffectSilent(EFFECT_OMERTA)
        v:delStatusEffectSilent(EFFECT_IMPAIRMENT)
        v:delStatusEffectSilent(EFFECT_DEBILITATION)
    end
end

local function teleportGroup(player, instance)
    local chars = instance:getChars()
    local pos = player:getPos()

    for i, v in pairs(chars) do
        if v:getID() ~= player:getID() then
            v:startEvent(3, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            v:timer(4000, function(p)
                p:setPos(pos.x, pos.y, pos.z, pos.rot)
            end)
        end
        v:setHP(v:getMaxHP())
        v:setMP(v:getMaxMP())
        if v:getPet() then
            local pet = v:getPet()
            pet:setHP(pet:getMaxHP())
            pet:setMP(pet:getMaxMP())
        end
    end
end

function onEventFinish(player, csid, option)
    local instance = player:getInstance()

    -- 2026-09-04: TEMP DEBUG (telepad investigation) -- remove once resolved
    -- print(string.format("[TELEPAD DEBUG] onEventFinish: player=%s csid=%d option=%s",
          -- player:getName(), csid, tostring(option)))

    -- 2026-09-04: real fix -- same shadowing bug as teleportGroup above. Zone.lua's csid==1 branch
    -- (warp everyone back to zone 72 after mission failure) was also unreachable for the same
    -- reason: this instance-level onEventFinish always wins over Zone.lua's, regardless of which
    -- csid branch it matches inside, so a real mission failure left the party stuck instead of
    -- being warped out.
    if csid == 1 then
        local chars = instance:getChars()
        stripPathos(instance)
        for i, v in pairs(chars) do
            v:setPos(0, 0, 0, 0, 72)
        end
    elseif csid >= 200 and csid <= 203 and option == 1 then
        for id = Arrapago.mobs[2][csid - 199].mobs_start, Arrapago.mobs[2][csid - 199].mobs_end do
            SpawnMob(id, instance)
        end
        instance:setProgress(csid - 199)
        for id = Arrapago.mobs[1][2].rampart, Arrapago.mobs[1][2].mobs_end do
            DespawnMob(id, instance)
        end
        teleportGroup(player, instance)
    elseif csid == 204 and option == 1 then
        for i = 1, 2 do
            for id = Arrapago.mobs[3][i].mobs_start, Arrapago.mobs[3][i].mobs_end do
                SpawnMob(id, instance)
            end
        end
        instance:setProgress(csid - 203)
            for id = Arrapago.mobs[2][4].mobs_start, Arrapago.mobs[2][0].astrologer do
                DespawnMob(id, instance)
            end
        DespawnMob(Arrapago.mobs[2][2].princess, instance)
        DespawnMob(Arrapago.mobs[2][3].wahzil, instance)
        teleportGroup(player, instance)
    elseif (csid == 205 or csid == 206) and option == 1 then
        for id = Arrapago.mobs[4][csid - 204].mobs_start, Arrapago.mobs[4][csid - 204].mobs_end do
            SpawnMob(id, instance)
            SpawnMob(Arrapago.mobs[4][csid - 204].rampart2, instance)
        end
        instance:setProgress(csid - 204)
        for id = Arrapago.mobs[3][1].mobs_start, Arrapago.mobs[3].qiqirn_mine_2 do
            DespawnMob(id, instance)
        end
        teleportGroup(player, instance)
    elseif (csid == 207 or csid == 208) and option == 1 then
        for i = 1, 3 do
            for id = Arrapago.mobs[5][csid - 206][i].mobs_start, Arrapago.mobs[5][csid - 206][i].mobs_end do
                SpawnMob(id, instance)
            end
        end
        -- 2026-09-05: real fix -- removed the 3rd SpawnMob call here (.rampart3). Confirmed via
        -- real sql/mob_spawn_points.sql: floor 5 has exactly 2 real ramparts per branch, never 3
        -- -- .rampart3 was nil in IDs.lua for BOTH branches (a shared upstream bug, also present
        -- in LSB's own reference), crashing this whole onEventFinish branch every time (no
        -- progression, no teleport, nothing past this point ever ran). Added the real missing
        -- rampart2 id for branch [2] in IDs.lua instead of inventing a rampart3.
        SpawnMob(Arrapago.mobs[5][csid - 206].rampart1, instance)
        SpawnMob(Arrapago.mobs[5][csid - 206].rampart2, instance)
        instance:setProgress(csid - 206)
        for id = Arrapago.mobs[4][1].mobs_start, Arrapago.mobs[4].qiqirn_mine_1 do
            DespawnMob(id, instance)
        end
        teleportGroup(player, instance)
    elseif csid == 209 and option == 1 then
        for id = Arrapago.mobs[6][1].mobs_start, Arrapago.mobs[6][1].mobs_end do
            SpawnMob(id, instance)
        end
        SpawnMob(Arrapago.mobs[6].rampart1, instance)
        SpawnMob(Arrapago.mobs[6].rampart2, instance)
        instance:setProgress(csid - 208)
        for id = Arrapago.mobs[5][1][1].mobs_start, Arrapago.mobs[5][2].chariot do
            DespawnMob(id, instance)
        end
        teleportGroup(player, instance)
    elseif csid == 210 and option == 1 then
        SpawnMob(Arrapago.mobs[7][1].chariot, instance)
        instance:setProgress(csid - 209)
        for id = Arrapago.mobs[6].rampart1, Arrapago.mobs[6].rampart4 do
            DespawnMob(id, instance)
        end
        teleportGroup(player, instance)
    elseif csid == 211 and option == 1 then
        -- 2026-09-05: working hypothesis, NOT confirmed -- csid 211 is the only real event in
        -- this zone's own dat with no baked-in client-side UPDATE_PLAYER_POS (every other telepad
        -- event 200-210/212 has one), meaning the server has to decide what happens next -- and
        -- its region (12) sits at _22j's own real position, right at the end of the instance past
        -- the boss floor. Wiring it to instance:complete() (real, confirmed API -- CInstance::
        -- Complete() -> sets INSTANCE_COMPLETE, clears entities, calls our own onInstanceComplete
        -- hook, currently an empty stub in both Topaz and LSB) since that's the one real, existing
        -- mechanism this event could plausibly be triggering -- not inventing new behavior, just
        -- connecting two already-real pieces. Live-confirmed 2026-09-05: dialog rendered,
        -- confirmed option reached the server, onEventFinish ran, stripPathos/instance:complete()
        -- both executed for real. But instance:complete() alone doesn't move anyone anywhere
        -- (confirmed via its own C++ body -- just sets status + clears entities + calls the still-
        -- empty onInstanceComplete hook) -- user report: "did not take me out of the zone or
        -- anything other than remove the pathos". Added the same exit-warp the mission-failed
        -- path (csid==1) already uses, so completing actually returns everyone to the hub instead
        -- of leaving them standing in a now-emptied instance (which also explains why it kept
        -- re-firing on every walk-through -- nothing ever moved the player out of the region).
        local chars = instance:getChars()
        stripPathos(instance)
        instance:complete()
        for i, v in pairs(chars) do
            v:setPos(0, 0, 0, 0, 72)
        end
    end
end

