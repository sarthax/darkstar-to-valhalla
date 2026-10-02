-----------------------------------------
-- ID: 5431
-- Item: Dusty Potion
-- Item Effect: Restores 300 HP -- confirmed via real BG Wiki excerpt supplied 2026-09-14 ("Dusty
-- Potion -> 300 HP Potion"). No Topaz source exists for this item (confirmed absent by direct
-- file check); built against old-dsp-reference's own already-real potion.lua/hi-potion.lua
-- pattern (fixed addHP + message id 24), but WITHOUT the ITEM_POWER multiplier and EFFECT_MEDICINE
-- cooldown those regular potions use -- matches this same drink family's own dusty_elixir.lua
-- (Topaz's real source), which also restores a flat amount with no potion-cooldown gating, since
-- Nyzul Isle's "dusty"-prefixed temp items are a separate reward system, not standard consumables.
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    target:messageBasic(24, 0, target:addHP(300));
end;
