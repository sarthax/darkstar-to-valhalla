-----------------------------------
-- func: gotoentity <id> [spawnedOnly]
-- desc: Test command for goToEntity() -- warps the player directly to a mob/NPC by id, including
--       across zones (exercises the MSG_SEND_TO_ENTITY two-hop message added to support this).
--       spawnedOnly: 0/omitted = fall back to the entity's mob_spawn_points row if not currently
--       spawned, 1 = do nothing if the entity isn't spawned right now.
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = "ii"
}

function onTrigger(player, id, spawnedOnly)
    if not id or id == 0 then
        player:PrintToPlayer("Usage: !gotoentity <id> [spawnedOnly]")
        return
    end

    player:PrintToPlayer(string.format("Going to entity %i...", id))
    player:goToEntity(id, spawnedOnly == 1)
end
