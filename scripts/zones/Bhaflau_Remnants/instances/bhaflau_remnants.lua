-----------------------------------
-- Salvage: Bhaflau Remnants
-----------------------------------
-- 2026-09-07: initial real skeleton -- makes the zone reachable/enterable and handles the two
-- confirmed-real, zone-wide Salvage mechanics (entry debuffs, mission-failure exit), same
-- structure as Arrapago Remnants' own instance file. Floor-progression logic (door csid handling,
-- stage/progress spawning) is intentionally NOT built yet -- real per-floor door csids, teleporter
-- coordinates, and mob-spawn sequencing for this zone are still being cross-referenced against a
-- real capture archive (D:/Claude/Salvage Captures Zips/Bhaflau Remnants/) that hasn't been fully
-- processed into IDs.lua yet. Confirmed real so far: door interaction csid 300 ("Gilded Doors",
-- same event family as Arrapago's own _220.lua), mission-failure csid 1 (IDs.lua's
-- MISSION_FAILED_CSID, cross-checked against Arrapago's own already-working onInstanceFailure).
require("scripts/globals/instance")
require("scripts/zones/Bhaflau_Remnants/IDs")
local doorUtil = require("scripts/zones/Bhaflau_Remnants/door_util")
-----------------------------------
-- 2026-09-07: real fix precedent applied here directly -- Arrapago's own afterInstanceRegister
-- originally applied these 5 Pathos debuffs with duration=0 (permanent, never expiring on its
-- own), fixed 2026-09-04 to LSB's real finite duration (6000s, matching Salvage's 100-minute time
-- limit). This is a zone-wide Salvage mechanic, not Arrapago-specific, so it's ported here as
-- already-fixed rather than reintroducing the same bug fresh.
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(Bhaflau.text.TIME_TO_COMPLETE, instance:getTimeLimit())
    player:addStatusEffectEx(EFFECT_ENCUMBRANCE_I, EFFECT_ENCUMBRANCE_I, 0xFFFF, 0, 6000)
    player:addStatusEffectEx(EFFECT_OBLIVISCENCE, EFFECT_OBLIVISCENCE, 0, 0, 6000)
    player:addStatusEffectEx(EFFECT_OMERTA, EFFECT_OMERTA, 0, 0, 6000)
    player:addStatusEffectEx(EFFECT_IMPAIRMENT, EFFECT_IMPAIRMENT, 0, 0, 6000)
    player:addStatusEffectEx(EFFECT_DEBILITATION, EFFECT_DEBILITATION, 0x1FF, 0, 6000)
    for i = 0, 15 do
        player:unequipItem(i)
    end
end

-- 2026-09-08: real fix -- the 2026-09-07 comment below ("door entities default to their real
-- npc_list status, already correct") was wrong for the WEST_EXIT/EAST_EXIT/CENTER groups
-- specifically. Every door's default SQL status is NORMAL (targetable) -- door_util.openAndAdvance
-- only locks the BRANCH pair itself (_231/_232) when one is chosen, it never hides the opposite
-- branch's own deeper exit group. Live-confirmed real bug: a player on the West branch could see/
-- target East's own _236 (EAST_EXIT) from the very start of the instance, since nothing had ever
-- untargeted it. CENTER is also untargetable at creation since it's meant to be reached by
-- walking through whichever EXIT group gets revealed by the real branch choice, not available
-- immediately.
function onInstanceCreated(instance)
    instance:setStage(1)
    instance:setProgress(0)

    for _, id in ipairs(Bhaflau.npcs.FLOOR1_GROUPS.WEST_EXIT) do
        local npc = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
        if npc then
            npc:untargetable(true)
        end
    end
    for _, id in ipairs(Bhaflau.npcs.FLOOR1_GROUPS.EAST_EXIT) do
        local npc = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
        if npc then
            npc:untargetable(true)
        end
    end
    for _, id in ipairs(Bhaflau.npcs.FLOOR1_GROUPS.CENTER) do
        local npc = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
        if npc then
            npc:untargetable(true)
        end
    end
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, Bhaflau.text)
end

-- 2026-09-08: real fix -- Bhaflau's telepads are region triggers (see Zone.lua's onInitialize for
-- the full writeup), not npc_list entities -- same mechanism as Arrapago Remnants' own confirmed-
-- working onRegionEnter (instances/arrapago_remnants.lua), csid = 199 + regionID, bare call (no
-- arg padding, matching this zone's own confirmed-working door event convention, _230.lua's
-- startEvent(300)).
--
-- 2026-09-08 (later): real fix, ported from LandSandBoat's own real onTriggerAreaEnter -- regions
-- 1-8 additionally gate on stageComplete == getStage() (set by the real door files, see
-- door_util.lua/IDs.lua's own comments) so a region can't fire out of order. Regions 9-10 are the
-- boss floor's 2 randomized exit points -- special-cased exactly like LSB: only fires if this
-- region is the one randomly chosen (instance localVar 'exitPoint'), and only actually completes
-- the run if the boss is confirmed dead (instance:completed()) -- otherwise a real "Nothing
-- happens..." message, matching LSB's own real behavior exactly.
-- 2026-09-09: real fix -- luautils::OnRegionEnter (luautils.cpp:1523) only ever calls this with 2
-- args, (player, region) -- there is no 3rd `instance` argument from the engine. The old signature
-- silently received nil for it, crashing every real telepad attempt ("attempt to index local
-- 'instance' (a nil value)"). Fixed to derive it from the player, same as every other handler in
-- this file already does.
function onRegionEnter(player, region)
    local instance = player:getInstance()
    local areaID = region:GetRegionID()

    if areaID <= 8 then
        if instance:getLocalVar("stageComplete") == instance:getStage() then
            player:startEvent(199 + areaID)
        end
    else
        if instance:getLocalVar("exitPoint") == areaID then
            if instance:completed() then
                player:startEvent(208)
            else
                player:messageSpecial(Bhaflau.text.NOTHING_HAPPENS)
            end
        end
    end
end

-- Same real mechanic as Arrapago's own teleportGroup: the triggering player's client already knows
-- where to go (baked into the csid event itself), so followers are moved to match the triggering
-- player's resulting position rather than a server-supplied destination -- avoids needing Floor 2's
-- still-unconfirmed real entry coordinates (see IDs.lua's own "STILL OPEN" tracking) to make the
-- telepad itself work.
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

-- 2026-09-07: real fix ported directly -- Arrapago's own onInstanceFailure originally used a
-- 10-arg zero-padded startEvent(1, 0,0,0,0,0,0,0,0,0) call, which produced a client-side
-- param-count mismatch (CEventPacket bakes the real param count into the packet) -- the event
-- fired server-side but the client never replied, so nothing visibly happened. Fixed to a bare
-- call there 2026-09-07; applying the same real fix here from the start rather than reintroducing
-- the bug fresh. Bhaflau.text.MISSION_FAILED_CSID (confirmed real, csid 1) is used directly since this
-- zone's IDs.lua hasn't split it into named sub-messages (MISSION_FAILED, TIME_TO_COMPLETE, etc.)
-- like Arrapago's has yet.
function onInstanceFailure(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:startEvent(Bhaflau.text.MISSION_FAILED_CSID)
    end
end

function onInstanceComplete(instance)
end

-- 2026-09-07: same real mechanic as Arrapago's own stripPathos -- these entry debuffs are scoped
-- to being inside the instance and should clear immediately on any real exit path (mission
-- failure or completion), not linger for whatever time was left on their 6000s safety-net
-- duration.
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

-- 2026-09-07: real fix ported directly -- same "instance-level onEventFinish always wins over
-- Zone.lua's" issue Arrapago hit is structurally identical here (luautils::LoadEventScript
-- resolves this file's onEventFinish first), so csid==1 (mission failure) is handled here, not
-- left to a Zone.lua fallback that would never actually run.
function onEventFinish(player, csid, option)
    local instance = player:getInstance()

    if csid == Bhaflau.text.MISSION_FAILED_CSID then
        local chars = instance:getChars()
        stripPathos(instance)
        for i, v in pairs(chars) do
            v:setPos(0, 0, 0, 0, 72)
        end
    -- 2026-09-08: real fix -- csid 200 is region 1's real telepad event (Zone.lua's onInitialize,
    -- live-confirmed position), the Floor-1-CENTER-to-Floor-2 transition. Advancing stage/progress
    -- and moving the party is the confirmed-safe part (same mechanism as Arrapago's own csid
    -- 200-210 handlers); NOT yet spawning/despawning any Floor 2 mob roster here -- unlike
    -- Arrapago's equivalent branches, Bhaflau's per-floor mob groupings in IDs.lua aren't split out
    -- stage-by-stage yet (only flat mob-type tables exist), so doing that now would mean guessing
    -- which ids belong to this transition instead of using confirmed data. Tracked as a followup,
    -- not fabricated here.
    elseif csid == 200 and option == 1 then
        -- 2026-09-09: real fix -- nothing ever unsealed FLOOR2_ENTRANCE (_23b/_23c) after this
        -- transition. door_util.lua's own onDoorOpen requires unSealed==1 to succeed -- without
        -- this, both Floor 2 entrance doors are permanently stuck reporting sealed, and since
        -- their onEventFinish (which spawns each room's real mob roster via doorUtil.spawnGroup)
        -- never runs either, this was also the real cause of "nothing spawns on Floor 2" --
        -- same root cause, not two separate bugs.
        instance:setStage(2)
        instance:setProgress(0)
        doorUtil.unsealDoors(instance, Bhaflau.npcs.FLOOR2_ENTRANCE)
        -- 2026-09-09: real fix -- BG Wiki: the Central Area's 4 Empathic Flan rooms sit right at
        -- the telepad, no door/trigger gating them at all -- they're just standing there from the
        -- start, same as this zone's other central encounters. Empathic_Flan's own mob_groups row
        -- is SPAWNTYPE_SCRIPTED (never auto-spawns), and nothing else in this codebase spawned it
        -- -- confirmed live ("nothing spawning on Floor 2"). Spawns all 4 real ids directly at
        -- this same telepad-arrival transition.
        doorUtil.spawnGroup(instance, { Bhaflau.mobs.EMPATHIC_FLAN })
        teleportGroup(player, instance)
    -- 2026-09-08: real fix, ported from LandSandBoat's own real onEventUpdate/onEventFinish csid
    -- dispatch -- regions 2-8 (csid 201-207). Door unsealing matches LSB's own real per-transition
    -- target lists exactly (see each comment below). Mob-group spawning at each of these
    -- transitions is NOT ported here -- LSB spawns those per-door (already wired into _23l.lua etc.
    -- above), not at the region-transition level, so nothing further is needed here for that part.
    elseif csid >= 201 and csid <= 204 and option == 1 then
        -- Stage 3: all 4 real entrance doors (NW/SW/NE/SE) unseal together regardless of which of
        -- the 4 regions triggered -- matches LSB's own real behavior exactly (the 4 Empathic Flan
        -- rooms share one Central Area, so reaching any one opens the same 4 downstream doors).
        instance:setStage(3)
        instance:setProgress(csid - 200)
        doorUtil.unsealDoors(instance, {
            Bhaflau.npcs.DOOR._23l, Bhaflau.npcs.DOOR._23n, Bhaflau.npcs.DOOR._23o, Bhaflau.npcs.DOOR._23q,
        })
        teleportGroup(player, instance)
    elseif csid >= 205 and csid <= 206 and option == 1 then
        instance:setStage(4)
        instance:setProgress(csid - 204)
        doorUtil.unsealDoors(instance, { Bhaflau.npcs.DOOR._23t, Bhaflau.npcs.DOOR._23u })
        -- 2026-09-09: real fix, REVERTED -- a previous pass here added an explicit player:setPos
        -- after concluding (wrongly) that this event had no baked client destination and that
        -- the two real Floor 4 landing spots were CROSSED relative to their triggers. Live-tested
        -- by the user: taking the real telepad landed correctly at first, then snapped to the
        -- OTHER (wrong) spot a few seconds later -- decoded both csid205 and csid206's real
        -- bytecode via mission_toolkit/explore_event.py to check instead of guessing further.
        -- Both DO carry a real baked player:setPosition() call (param order x,z,y,rot, not
        -- x,y,z,rot -- easy to misread) -- csid205 -> real West landing (-460,-0.499,-20,0),
        -- csid206 -> real East landing (-220,-0.499,-20,128) -- i.e. SAME-SIDE, not crossed. The
        -- earlier "no baked destination" conclusion was simply wrong, and the added setPos was
        -- racing against this real one with the wrong (crossed) coordinates -- removed entirely,
        -- letting the baked event (which already has its own correct fade/wait via reqSetWait)
        -- handle the whole warp alone, same as every other real telepad in this zone.
        -- 2026-09-09: real fix -- user confirmed Floor 4's Archaic Gear/Gears/Chariot rosters
        -- were never actually spawned anywhere (their own onMobDeath/onMobEngaged/onMobFight
        -- mechanics were wired earlier, but nothing ever called SpawnMob). Split by real position
        -- into West/East clusters (IDs.lua's own ARCHAIC_GEAR/ARCHAIC_GEARS/ARCHAIC_CHARIOT --
        -- EAST cluster centers on Chariot 17084665 at x=-256, WEST on Chariot 17084681 at
        -- x=-419.4) and spawned at the matching real telepad landing -- csid205 (West landing,
        -- -460) spawns the West cluster, csid206 (East landing, -220) spawns the East cluster.
        if csid == 205 then
            doorUtil.spawnGroup(instance, {
                doorUtil.slice(Bhaflau.mobs.ARCHAIC_GEAR, 11, 20),
                doorUtil.slice(Bhaflau.mobs.ARCHAIC_GEARS, 6, 10),
                Bhaflau.mobs.ARCHAIC_CHARIOT[2],
            })
        else
            doorUtil.spawnGroup(instance, {
                doorUtil.slice(Bhaflau.mobs.ARCHAIC_GEAR, 1, 10),
                doorUtil.slice(Bhaflau.mobs.ARCHAIC_GEARS, 1, 5),
                Bhaflau.mobs.ARCHAIC_CHARIOT[1],
            })
        end
        teleportGroup(player, instance)
    elseif csid == 207 and option == 1 then
        instance:setStage(5)
        instance:setProgress(1)
        doorUtil.unsealDoors(instance, Bhaflau.npcs.DOOR._23v)
        -- 2026-09-09: real fix -- user confirmed Long-Bowed Chariot never spawns on Floor 5 at
        -- all. Same real bug class as Empathic Flan/Floor 4's Gears -- the real id
        -- (LONG_BOWED_CHARIOT) already existed, but nothing anywhere ever called SpawnMob for
        -- it. Spawns it at this same telepad-arrival transition, matching every other floor's
        -- boss/roster spawn pattern in this zone.
        SpawnMob(Bhaflau.mobs.LONG_BOWED_CHARIOT, instance)
        -- Real mechanic (LSB): the boss floor's exit is one of 2 randomized real positions,
        -- chosen once here and checked against in onRegionEnter (regions 9/10) above.
        instance:setLocalVar("exitPoint", math.random(9, 10))
        teleportGroup(player, instance)
    elseif csid == 208 and option == 1 then
        -- Real mechanic (LSB): fires once the boss is confirmed dead and the party reaches the
        -- randomly-chosen real exit point (see onRegionEnter above). LSB's own version calls
        -- entity:startCutscene(1) here -- no such binding exists in this Topaz fork, and csid 1 is
        -- already this zone's own MISSION_FAILED_CSID (see the top of this function), so reusing
        -- it here would wrongly trigger the failure branch instead. instance:complete() alone
        -- (already called from Long-Bowed_Chariot.lua's onMobDeath) doesn't move anyone anywhere,
        -- per Arrapago's own real, already-documented precedent for the identical situation -- so
        -- this uses that same safe pattern (strip debuffs, warp to the entrance zone) instead of
        -- inventing a cutscene csid.
        stripPathos(instance)
        local chars = instance:getChars()
        for i, v in pairs(chars) do
            v:setPos(0, 0, 0, 0, 72)
        end
    end

    -- 2026-09-07: TEMP DEBUG -- real per-floor door/teleporter csids aren't all confirmed yet (see
    -- file header). Logging every other csid here so a real walkthrough gives us the actual
    -- sequence to build the rest of this function against, instead of guessing.
    local knownCsids = {
        [200] = true, [201] = true, [202] = true, [203] = true, [204] = true,
        [205] = true, [206] = true, [207] = true, [208] = true,
    }
    if csid ~= Bhaflau.text.MISSION_FAILED_CSID and not knownCsids[csid] then
        -- print(string.format("[BHAFLAU DEBUG] onEventFinish: player=%s csid=%d option=%s",
              -- player:getName(), csid, tostring(option)))
    end
end

