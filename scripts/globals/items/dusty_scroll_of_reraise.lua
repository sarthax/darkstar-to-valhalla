-----------------------------------------
-- ID: 5436
-- Item: Dusty Scroll of Reraise
-- Item Effect: Grants Reraise III -- confirmed via real BG Wiki excerpt supplied 2026-09-14
-- ("Dusty Reraise -> Reraise III"). No Topaz source exists for this item (confirmed absent by
-- direct file check); built from scratch against old-dsp-reference's own already-real,
-- already-working reraise item pair (reraiser.lua = Reraise power 1, hi-reraiser.lua = Reraise
-- power 2) -- same EFFECT_RERAISE binding, power=3 for the Reraise III tier this wiki confirms.
-- Duration is NOT independently confirmed for this specific item -- reused reraiser.lua's own
-- 3600s (1hr) real duration as the closest confirmed precedent rather than inventing a new number;
-- flag for correction if a real capture/wiki duration for this specific item turns up.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local duration = 3600;

    target:delStatusEffect(EFFECT_RERAISE);
    target:addStatusEffect(EFFECT_RERAISE, 3, 0, duration);
end;
