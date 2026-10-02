-----------------------------------------
-- ID: 5432
-- Item: Dusty Ether
-- Item Effect: Restores 150 MP -- confirmed via real BG Wiki excerpt supplied 2026-09-14 ("Dusty
-- Ether -> 150 MP Potion"). No Topaz source exists for this item (confirmed absent by direct file
-- check); built against old-dsp-reference's own already-real ether.lua pattern (fixed addMP +
-- message id 25), same "no ITEM_POWER/EFFECT_MEDICINE gating" reasoning as this drink family's
-- dusty_potion.lua sibling.
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    target:messageBasic(25, 0, target:addMP(150));
end;
