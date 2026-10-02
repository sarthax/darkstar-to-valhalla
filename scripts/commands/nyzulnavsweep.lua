-----------------------------------
-- func: nyzulnavsweep
-- desc: GM diagnostic -- sweeps EVERY point in Nyzul.lampSpawnPoints and
--       Nyzul.layoutSpawnPoints (scripts/globals/nyzul/floor_layouts.lua), for all 17 layouts,
--       against the zone's real compiled navmesh. For each point, checks:
--         1. zone:checkNavPosition(x,y,z) -- does a walkable polygon exist there at all
--         2. zone:checkNavPath(anchor, point) -- is there an actual connected route from that
--            layout's own real starting/anchor position (the coordinate given in that layout's own
--            comment in floor_layouts.lua) to the point
--       A point that fails #1 is flagged off-mesh (bad raw coordinate). A point that passes #1 but
--       fails #2 is flagged unreachable-from-anchor -- the exact "monster can wallhack there but a
--       player cannot walk there" symptom the user reported (a real navmesh gap/closed-door area
--       between the anchor and that point, not a bad coordinate). Both are printed to the
--       map-server console (grep-able) and to the calling player. Since Nyzul Isle's floor rooms
--       are fixed physical geometry (not regenerated per instance), this check works from
--       anywhere in the Nyzul_Isle zone -- no live instance/floor roll needed.
-----------------------------------
require("scripts/globals/nyzul/floor_layouts")
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = ""
}

-- Real per-layout anchor/reference position -- lifted verbatim from each layout's own inline
-- comment in floor_layouts.lua (the room's real starting/entrance area), used as the "player
-- position" checkNavPath needs a real route FROM. Layout 17 (boss room) has no lamp table entry
-- of its own to source a comment from beyond its own anchor line -- included directly.
local LAYOUT_ANCHORS =
{
    [1]  = { x =  380, y = -0.5, z = -500 },
    [2]  = { x =  500, y = -0.5, z =  -20 },
    [3]  = { x =  500, y = -0.5, z =   60 },
    [4]  = { x =  500, y = -0.5, z = -100 },
    [5]  = { x =  540, y = -0.5, z = -140 },
    [6]  = { x =  460, y = -0.5, z = -219 },
    [7]  = { x =  420, y = -0.5, z =  500 },
    [8]  = { x =   60, y = -0.5, z = -335 },
    [9]  = { x =   20, y = -0.5, z = -500 },
    [10] = { x =  -95, y = -0.5, z =   60 },
    [11] = { x =  100, y = -0.5, z =  100 },
    [12] = { x = -460, y = -4.0, z = -180 },
    [13] = { x = -304, y = -0.5, z = -380 },
    [14] = { x = -380, y = -0.5, z = -500 },
    [15] = { x = -459, y = -4.0, z = -540 },
    [16] = { x = -465, y = -4.0, z = -340 },
    [17] = { x =  504.5, y =  0.0, z =  -60 },
}

-- layoutSpawnPoints entries are {x=,y=,z=} tables; lampSpawnPoints entries are plain {x,y,z}
-- arrays -- normalize both to {x,y,z} here so the sweep loop doesn't care which table it's on.
local function coord(entry)
    if entry.x ~= nil then
        return entry.x, entry.y, entry.z
    end
    return entry[1], entry[2], entry[3]
end

local function sweepTable(player, zone, tableName, tbl, offMesh, unreachable, totalChecked)
    for layout, points in pairs(tbl) do
        local anchor = LAYOUT_ANCHORS[layout]
        if not anchor then
            player:PrintToPlayer(string.format("[NAVSWEEP] WARNING: no anchor for layout %d (%s) -- skipped.", layout, tableName))
        else
            for idx, entry in pairs(points) do
                local x, y, z = coord(entry)
                totalChecked[1] = totalChecked[1] + 1

                local validPos = zone:checkNavPosition(x, y, z)
                if not validPos then
                    table.insert(offMesh, string.format("%s layout=%d idx=%d (%.1f, %.1f, %.1f) -- OFF-MESH (no polygon here)",
                        tableName, layout, idx, x, y, z))
                else
                    local pathFound = zone:checkNavPath(anchor.x, anchor.y, anchor.z, x, y, z)
                    if not pathFound then
                        table.insert(unreachable, string.format("%s layout=%d idx=%d (%.1f, %.1f, %.1f) -- UNREACHABLE from anchor (%.1f, %.1f, %.1f)",
                            tableName, layout, idx, x, y, z, anchor.x, anchor.y, anchor.z))
                    end
                end
            end
        end
    end
end

function onTrigger(player)
    local zone = player:getZone()

    if zone:getID() ~= 77 then
        player:PrintToPlayer("[NAVSWEEP] You must be standing in the Nyzul_Isle zone to run this (the navmesh being checked is zone-bound).")
        return
    end

    local offMesh = {}
    local unreachable = {}
    local totalChecked = { 0 }

    sweepTable(player, zone, "lampSpawnPoints", Nyzul.lampSpawnPoints, offMesh, unreachable, totalChecked)
    sweepTable(player, zone, "layoutSpawnPoints", Nyzul.layoutSpawnPoints, offMesh, unreachable, totalChecked)

    player:PrintToPlayer(string.format("[NAVSWEEP] Checked %d points across 17 layouts. off-mesh=%d unreachable-from-anchor=%d",
        totalChecked[1], #offMesh, #unreachable))
    print(string.format("[NAVSWEEP] Checked %d points across 17 layouts. off-mesh=%d unreachable-from-anchor=%d",
        totalChecked[1], #offMesh, #unreachable))

    for _, line in ipairs(offMesh) do
        print("[NAVSWEEP OFFMESH] " .. line)
        player:PrintToPlayer(line)
    end
    for _, line in ipairs(unreachable) do
        print("[NAVSWEEP UNREACHABLE] " .. line)
        player:PrintToPlayer(line)
    end

    if #offMesh == 0 and #unreachable == 0 then
        player:PrintToPlayer("[NAVSWEEP] No issues found -- every point is on-mesh and reachable from its layout's anchor.")
    end
end
