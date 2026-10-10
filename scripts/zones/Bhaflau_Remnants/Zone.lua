-----------------------------------
--
-- Zone: Bhaflau_Remnants
--
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
-----------------------------------
-- 2026-09-08: real fix -- Bhaflau's telepads are region triggers, same mechanism as Arrapago
-- Remnants' own confirmed-working ones (Arrapago_Remnants/Zone.lua's onInitialize + its instance
-- script's onRegionEnter/onEventFinish), NOT npc_list entities -- confirmed by finding no SQL row
-- anywhere near two coordinates the user live-tested standing on/near an in-game telepad, then
-- finding Arrapago's own telepads use zone:registerRegion() with no backing npc/id at all for the
-- identical reason (its own Zone.lua comment: "no SQL/npc_list entity to find or tie either of
-- these to"). Region 1 below is the real Floor-1-CENTER-to-Floor-2 telepad, live-confirmed via
-- !logpos (340.0055,-1.0000,-420.2561) -- sits ~20 yalms past the real _23a CENTER door
-- (17084899, 340.000,-2.012,-400.000), consistent with a telepad just beyond the door rather than
-- on top of it. csid mapping uses the same 199+regionID convention Arrapago uses (confirmed, not
-- guessed): region 1 -> csid 200, matching the first of the real 0x00C8/0x00C9/0x00CD/0x00CF/0x00D0
-- csids capture #110 already showed on the player (IDs.lua header, "STILL OPEN" section) --
-- 0x00C8 = 200. Radius param is 5 per Arrapago's own real bug note (CRegion::isPointInside uses
-- the 2nd arg as radius, not a Y-coordinate).
-- 2026-09-08: real fix -- regions 2-10 added, ported directly from LandSandBoat's own real,
-- working Zone.lua (zone:registerCylindricalTriggerArea(id, x, z, radius)). Region 1's own real
-- coordinates already matched LSB's exactly (confirmed via live user test before this port), so
-- these are trusted the same way -- same world geometry, just a different registration API
-- (Topaz: registerRegion(id, x, RADIUS, z, ...); LSB: registerCylindricalTriggerArea(id, x, z,
-- RADIUS) -- note the different argument order). Radius kept at 5 (Topaz's own real bug-workaround
-- value, not LSB's literal "4") per the existing comment below. Regions 2-8 use the same
-- 199+regionID csid convention as region 1; regions 9-10 are the boss floor's 2 randomized exit
-- points, handled specially in the instance script's own onRegionEnter (not a flat csid mapping).
--
-- 2026-09-09: live-confirmed -- regions 2-5 (Floor 2's 4 exit telepads) checked via real user
-- !logpos at each of the 4 spots (just past _23h/_23i/_23j/_23k): (260.18,300.20),
-- (299.99,60.35), (420.06,300.37), (379.48,59.92) -- all match the LSB-ported values above almost
-- exactly. The apparent asymmetry (SW/SE sitting closer to map center than their own exit doors,
-- unlike NW/NE which sit right at their door's x) is real room geometry, not a port error.
function onInitialize(zone)
    zone:registerRegion(1, 340.0055, 5, -420.2561, 0, 0, 0)
    zone:registerRegion(2, 260, 5, 300, 0, 0, 0)
    zone:registerRegion(3, 300, 5, 60, 0, 0, 0)
    zone:registerRegion(4, 420, 5, 300, 0, 0, 0)
    zone:registerRegion(5, 380, 5, 60, 0, 0, 0)
    zone:registerRegion(6, -460, 5, -500, 0, 0, 0)
    zone:registerRegion(7, -220, 5, -500, 0, 0, 0)
    zone:registerRegion(8, -340, 5, 60, 0, 0, 0)
    zone:registerRegion(9, -380, 5, 380, 0, 0, 0)
    zone:registerRegion(10, -300, 5, 380, 0, 0, 0)
end

-- 2026-09-09: real fix -- the North-facing fix was only ever wired into onInstanceCreated, which
-- fires exactly ONCE, at the moment the instance is first created. Every subsequent zone-in (the
-- real path exercised by re-testing the same long-lived instance all session) goes through this
-- hook instead, which never set any position/rotation at all -- explaining why the earlier fix
-- appeared to do nothing. Added the same real spawn position/rotation here.
function onZoneIn(player, prevZone)
    local cs = -1

    player:addTempItem(5400)
    player:setPos(0, 0, 0, 192)

    return cs
end

function onRegionEnter(player, region)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

-----------------------------------
-- GM-command fallback for !warpassault (2026-09-04) -- mirrors Arrapago_Remnants/Zone.lua's real,
-- already-working onInstanceCreated exactly (zoneid changed to this zone's own, 75).
-----------------------------------
-- 2026-09-09: real fix -- rot was 0. Per this zone's own confirmed rot convention (0 = East,
-- clockwise, calibrated via the Dormant Rampart facing fix: East(0) -> South(64) -> West(128) ->
-- North(192)), 0 spawned the player facing East. User requested facing North on zone-in -- 192.
function onInstanceCreated(player, target, instance)
    if instance then
        player:setInstance(instance)
        player:setPos(0, 0, 0, 192, 75)
    end
end

