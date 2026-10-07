-----------------------------------
-- func: setstage <stage> [progress]
-- desc: GM debug command - jumps your CURRENT instance directly to the given
--       stage/progress, skipping replaying the whole run to get back there
--       for testing. Does NOT replicate any door's own reveal/spawn logic
--       (SpawnMob calls, npc:setStatus(NORMAL) reveal loops, etc) -- only
--       raw instance:setStage()/setProgress(). Entities whose npc_list row
--       already defaults to status=0 (NORMAL) will still show up fine;
--       anything that only becomes visible/spawned via a specific door's
--       onEventFinish will need that door triggered normally, or its mobs
--       spawned separately (e.g. !spawnmob if available).
--
-- Usage: !setstage 7        -- sets stage=7, progress=0
--        !setstage 7 2      -- sets stage=7, progress=2
-----------------------------------
cmdprops =
{
    permission = 1,
    parameters = "ii"
}

function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!setstage <stage> [progress]")
end

function onTrigger(player, stage, progress)
    local instance = player:getInstance()

    if not instance then
        error(player, "You are not inside an instance.")
        return
    end

    stage = tonumber(stage)
    if stage == nil then
        error(player, "Invalid stage.")
        return
    end

    progress = tonumber(progress) or 0

    instance:setStage(stage)
    instance:setProgress(progress)

    player:PrintToPlayer(string.format("[SETSTAGE] instance %d now at stage=%d progress=%d",
        instance:getID(), stage, progress))
end
