-----------------------------------
--
-- Zone: Arrapago Remnants
--
-----------------------------------
require("scripts/zones/Arrapago_Remnants/IDs")
-----------------------------------
function onInitialize(zone)
    zone:registerRegion(1, 420, 5, -339, 0, 0, 0)
    zone:registerRegion(2, 420, 5, -499, 0, 0, 0)
    zone:registerRegion(3, 259, 5, -499, 0, 0, 0)
    zone:registerRegion(4, 259, 5, -339, 0, 0, 0)
    zone:registerRegion(5, 340, 5, 100, 0, 0, 0)
    zone:registerRegion(6, 339, 5, 419, 0, 0, 0)
    zone:registerRegion(7, 339, 5, 500, 0, 0, 0)
    zone:registerRegion(8, -379, 5, -620, 0, 0, 0)
    zone:registerRegion(9, -300, 5, -461, 0, 0, 0)
    zone:registerRegion(10, -339, 5, -99, 0, 0, 0)
    zone:registerRegion(11, -339, 5, 300, 0, 0, 0)
    -- 2026-09-06: real fix -- REPOSITIONED region 12, and region 13 now registered. The
    -- -339.9123/491.327 spot used below through 2026-09-05 was confirmed mechanically working
    -- (csid 211 fired, pathos cleared) but the user found via real video playthrough that it was
    -- the wrong physical location -- the real final room has TWO symmetric telepads, both marked
    -- with an exit "X" on the level's own annotated map. User personally confirmed via live
    -- !logpos which one is the real full-instance exit:
    --   -379.6961, -1.0000, 580.2968  -- confirmed: this is the one actually used to exit
    --   -300.4364, -1.0000, 580.2823  -- the symmetric other one, unconfirmed function
    -- These sit almost exactly symmetric around x=-340 (the same x as the _22g/_22h/_22i door
    -- cluster one floor back), consistent with a real final-room layout with a telepad on each
    -- side. Neither telepad is npc/prop-based -- confirmed via the real TacoCat capture: its one
    -- csid 211 interaction shows NPC=449586 (Tacocat, the player's own entity id), the same
    -- self-triggered-proximity signature as every other region event in this zone, not a real
    -- prop id -- so there is no SQL/npc_list entity to find or tie either of these to.
    -- Region 13 really does trigger csid 212 client-side (real destination baked in:
    -- 420,-0.499,20, back to floor 2) -- confirmed live. REVERTED to firing csid 211 (full exit)
    -- instead, same as region 12: user live-tested the floor-2 return and found it's a dead end,
    -- since floor doors seal shut permanently once the instance advances stage -- a player using
    -- this telepad after progressing would get stuck with no way forward or back. See
    -- instances/arrapago_remnants.lua's onRegionEnter for the actual csid override.
    -- REAL BUG FOUND AND FIXED (still applies): CRegion::isPointInside (region.cpp) uses the
    -- SECOND parameter as the circle's RADIUS, not a Y-coordinate -- confirmed directly in the C++
    -- source (`return distance <= y1;` where distance is the real x/z-only distance). Every other
    -- region in this file uses 5 there for exactly this reason -- keep doing so, not the real
    -- world Y height.
    zone:registerRegion(12, -379.6961, 5, 580.2968, 0, 0, 0)
    zone:registerRegion(13, -300.4364, 5, 580.2823, 0, 0, 0)
    -- 2026-09-06: user-requested convenience -- the old "Weather" spot (region 12's position
    -- before repositioning to the real exit above) still fires the same real exit (csid 211),
    -- special-cased in instances/arrapago_remnants.lua since it doesn't fit the 199+regionID
    -- formula. Saves players who already know this spot some running; doesn't replace or block
    -- either real telepad.
    zone:registerRegion(14, -339.9123, 5, 491.327, 0, 0, 0)
end

function onInstanceZoneIn(player, instance)
    local cs = -1

    local pos = player:getPos()
    if (pos.x == 0 and pos.y == 0 and pos.z == 0) then
        local entrypos = instance:getEntryPos()
        player:setPos(entrypos.x, entrypos.y, entrypos.z, entrypos.rot)
    end

    player:addTempItem(5399)
end

function onRegionEnter(player, region)
end

function onEventUpdate(player, csid, option)
end

-- 2026-09-04: real fix -- this csid==1/200-210 logic was moved to
-- instances/arrapago_remnants.lua's own onEventFinish. luautils::LoadEventScript always resolves
-- the instance script's onEventFinish before this one while a player is inside the instance (which
-- is effectively always, once OnRegionEnter has run once), so this handler was unreachable dead
-- code -- confirmed via a real crash + debugger trace this session tracing why the floor-teleport
-- never fired. Left as a no-op stub since PChar->PInstance being unset here (the only case this
-- CAN run) means csid 1/200-210 should never occur through this path anyway.
function onEventFinish(player, csid, option)
end

function onInstanceLoadFailed()
    return 72
end

-----------------------------------
-- GM-command fallback for !warpassault (2026-08-18) -- see
-- Leujaoam_Sanctum/Zone.lua for the full explanation of why this is here.
-----------------------------------
function onInstanceCreated(player, target, instance)
    if instance then
        player:setInstance(instance)
        player:setPos(0, 0, 0, 0, 74)
    end
end

