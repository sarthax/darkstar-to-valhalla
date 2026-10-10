-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Lamia Fatedealer
-----------------------------------
-----------------------------------
-- 2026-09-04: real fix -- progress moved here from onMobDespawn, which fires on ANY despawn
-- (leash/reset included), not just a real kill -- gated on isKiller so a leashed mob can't
-- silently advance the count toward the Archaic Rampart's spawn threshold.
-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- pending a full
-- mob_droplist audit/correction instead of Lua-side addTreasure() calls, which bypass Treasure
-- Hunter and duplicate the native C++ drop-table system (see chat).
function onMobDeath(mob, player, isKiller)
    local instance = mob:getInstance()
    if instance:getStage() == 1 and isKiller then
        instance:setProgress(instance:getProgress() + 1)
    end
end

function onMobDespawn(mob)
end

