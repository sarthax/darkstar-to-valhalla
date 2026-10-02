-----------------------------------
-- func: navdebug [radius] [namefilter]
--       navdebug spawn [radius] [modelid]
-- desc: GM diagnostic tool -- added 2026-08-24, companion to !showhelper. Lists every NPC entity
--       loaded in your current instance within <radius> yalms (default 25) of you, with its real
--       live position, distance, facing, and whether that exact position sits on the compiled
--       navmesh (zone:checkNavPosition -- the SAME static navmeshes/<zone>.nav file loaded once
--       at zone startup, see CZone::LoadNavMesh in src/map/zone.cpp). Built to turn "walk into a
--       room and see everything at a glance" into an actual command instead of one !showhelper
--       call per suspect id.
--
-- IMPORTANT, read before using this to chase a "won't unlock" bug: the navmesh is a static,
-- pre-baked file -- it is NOT generated or modified at runtime from npc_list/instance_entities
-- positions. Moving a door/helper prop's coordinates (live or in SQL) can never change what's
-- walkable; it only changes where that prop's own visual/animation/trigger sits. There are two
-- genuinely different bug classes this command helps tell apart:
--   1. The prop itself is offset/missing/wrong-state (door looks shut, but the floor underneath
--      was always walkable) -- a real, fixable SQL/instance_entities/Lua bug. Diagnosed by: the
--      prop shows up in this scan at the wrong spot relative to where you expected the door, OR
--      an id you expected is MISSING from the scan entirely (meaning it's not registered in
--      instance_entities for this instance at all -- getNpcs() only returns what's actually
--      loaded, so absence from this list IS the "not registered" signal, no separate flag needed).
--   2. The navmesh itself has a real gap baked in at that spot -- no prop, no repositioning, and
--      no live "helper move" trick can ever fix this. Diagnosed by: checkNavPosition/checkNavPath
--      (already surfaced per-row below, or run !checknav directly) coming back false/no-path even
--      though a prop sits right there with the right state -- that means the source geometry the
--      navmesh was compiled from needs fixing, not the prop.
--
-- "spawn" mode additionally clears untargetable and swaps the model on every matched entity so
-- they're easier to spot/target by eye (visual only, same untargetable()/setModelId() calls as
-- !showhelper -- does not touch collision or entityFlags). Reverts on the next zone/instance
-- reload; there is no live "clear" since undoing correctly would require remembering each
-- entity's original model/flag state per id, which isn't tracked here.
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = "sss"
}

local DEFAULT_RADIUS = 25
local DEFAULT_SPAWN_MODEL = 1168 -- arbitrary distinct model, see setModelId()'s own doc example; override with the modelid arg if it's not obvious enough against your terrain

function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!navdebug [radius] [namefilter]")
    player:PrintToPlayer("!navdebug spawn [radius] [modelid]")
end

local function scan(player, radius, namefilter)
    local instance = player:getInstance()
    if not instance then
        player:PrintToPlayer("You must be inside an instance for this (uses instance:getNpcs()).")
        return {}
    end

    local px, py, pz = player:getXPos(), player:getYPos(), player:getZPos()
    local zone = player:getZone()
    local results = {}

    for _, npc in pairs(instance:getNpcs()) do
        local name = npc:getName()
        if not namefilter or namefilter == "" or string.find(string.lower(name), string.lower(namefilter), 1, true) then
            local x, y, z = npc:getXPos(), npc:getYPos(), npc:getZPos()
            local dx, dy, dz = x - px, y - py, z - pz
            local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
            if dist <= radius then
                table.insert(results, {
                    npc = npc,
                    name = name,
                    x = x, y = y, z = z,
                    rot = npc:getRotPos(),
                    dist = dist,
                    onMesh = zone:checkNavPosition(x, y, z),
                })
            end
        end
    end

    table.sort(results, function(a, b) return a.dist < b.dist end)
    return results
end

function onTrigger(player, arg1, arg2, arg3)
    local spawnMode = arg1 == "spawn"

    local radiusArg = spawnMode and arg2 or arg1
    local extraArg   = spawnMode and arg3 or arg2

    local radius = tonumber(radiusArg) or DEFAULT_RADIUS
    local modelid = spawnMode and (tonumber(extraArg) or DEFAULT_SPAWN_MODEL) or nil
    local namefilter = (not spawnMode) and extraArg or nil

    local results = scan(player, radius, namefilter)

    player:PrintToPlayer(string.format("== navdebug: %u entit%s within %u yalms ==",
        #results, #results == 1 and "y" or "ies", radius))

    for _, r in pairs(results) do
        player:PrintToPlayer(string.format("[%u] %s  pos=%.2f,%.2f,%.2f rot=%u dist=%.2f onMesh=%s",
            r.npc:getID(), r.name, r.x, r.y, r.z, r.rot, r.dist, tostring(r.onMesh)))

        if spawnMode then
            r.npc:untargetable(false)
            r.npc:setModelId(modelid)
        end
    end

    if spawnMode then
        player:PrintToPlayer(string.format("Spawned markers (model %u) -- reverts on next zone/instance reload.", modelid))
    end
end
