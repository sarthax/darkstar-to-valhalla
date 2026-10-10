-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Mad Bomber
-----------------------------------
-- 2026-09-08: real mechanic per BG Wiki (confirmed via user-provided map/wiki text this session):
-- "Defeating Mad Bomber will cause a Dormant Rampart to spawn... If Mad Bomber uses Self-Destruct
-- the Dormant Rampart will not spawn." Self-Destruct is a real, already-wired mob skill --
-- Mad_Bomber's real poolid (2471) uses skill_list_id 56, confirmed named 'Bomb' in
-- sql/mob_skill_lists.sql and containing real skill 511 ('self-destruct', active). The shared
-- handler (scripts/globals/mobskills/self-destruct.lua) now sets a generic
-- mob:setLocalVar("selfDestructed", 1) flag on itself right before mob:setHP(0), which is the only
-- reliable way to tell a Self-Destruct death apart from a normal kill here -- onMobDeath's own
-- player/isKiller args can't do it (isKiller only reflects kill credit, not what actually caused
-- the HP loss).
-- NOTE: only one real MAD_BOMBER id exists in IDs.lua (17084481) despite the real mechanic having
-- one per branch (West/East, see BG Wiki map) -- same known limitation as
-- Reactionary_Rampart.lua's DORMANT_RAMPART/REACTIONARY_RAMPART array indexing, pending real
-- per-branch ids/positions.
-----------------------------------
require("scripts/globals/status")
require("scripts/zones/Bhaflau_Remnants/IDs")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    if mob:getLocalVar("selfDestructed") == 1 then
        return
    end

    local instance = mob:getInstance()
    if not instance then
        return
    end

    -- 2026-09-08: real fix -- Dormant Rampart is a real NPC (npc_list.sql), not a mob -- confirmed
    -- via LandSandBoat's own reference after live testing showed it spawning as an attackable,
    -- one-hit-killable combat mob that never actually triggered the warp.
    --
    -- 2026-09-08 (later): real fix -- there's only ONE real Dormant Rampart id per floor
    -- (DORMANT_RAMPART[1] for Floor 1), but Mad Bomber has 2 real candidate pop spots per branch,
    -- each with its OWN confirmed real Dormant Rampart destination
    -- (ID.pos.DORMANT_RAMPART.WEST/.EAST) -- live-confirmed: killing Mad Bomber at WEST pop-index 2
    -- did NOT reveal a rampart at pop-index 1's position (236,-460), it needed its own
    -- (259.9364,-282.9339). Reposition the one real entity to the matching spot using the popIndex
    -- _231.lua/_232.lua recorded when Mad Bomber spawned, same "one real entity, repositioned by
    -- index" pattern already used for Mad Bomber itself. Both branches now have both real spots
    -- confirmed via live user tests.
    local dormant = instance:getEntity(bit.band(Bhaflau.mobs.DORMANT_RAMPART[1], 0xFFF), TYPE_NPC)
    if dormant then
        local branch = instance:getLocalVar("BhaflauFloor1Branch")
        local popIndex = mob:getLocalVar("popIndex")
        local positions
        if branch == 2 then
            positions = ID.pos.DORMANT_RAMPART.WEST
        elseif branch == 1 then
            positions = ID.pos.DORMANT_RAMPART.EAST
        end
        local pos = positions and positions[popIndex]
        if pos then
            dormant:setPos(pos[1], pos[2], pos[3], pos[4])
        end
        dormant:setStatus(STATUS_NORMAL)
    end
end

function onMobDespawn(mob)
    mob:setLocalVar("selfDestructed", 0)
end

