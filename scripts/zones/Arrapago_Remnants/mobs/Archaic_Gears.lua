-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Archaic Gears
-----------------------------------
mixins = {require("scripts/mixins/families/gears")}
-----------------------------------
-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- this mob already has
-- a real, non-zero dropid (158) in mob_groups pointing to a real mob_droplist entry, which the
-- native C++ DropItems()/GetDropList() path already rolls (with real Treasure Hunter support).
-- The Lua addTreasure() calls were stacking a second, TH-blind drop system on top of that --
-- reverted pending a full mob_droplist audit/correction instead (see chat). Note: that existing
-- mob_droplist row (158) itself may have the same base-zone-vs-Remnants-II conflation problem
-- (it currently includes Piece of Alexandrite/Arrapago Card, both confirmed Remnants-II-only via
-- BG Wiki) -- flagged for the same audit, not fixed here.
-----------------------------------
function onMobDeath(mob, player, isKiller)
    local instance = mob:getInstance()
    if (instance:getStage() == 6 and instance:getProgress() >= 1) then
        if (isKiller) then
            instance:setProgress(instance:getProgress() + 1)
        end
    end
end

function onMobDespawn(mob)
end

