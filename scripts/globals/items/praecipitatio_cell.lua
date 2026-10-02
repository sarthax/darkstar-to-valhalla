-----------------------------------
-- Praecipitatio Cell
-- ID 5375
-- Unlocks magic
-----------------------------------
require("scripts/globals/status")
-----------------------------------
function onItemCheck(target)
    if target:hasStatusEffect(EFFECT_OMERTA) then
        return 0
    end
    return -1
end

function onItemUse(target)
    target:delStatusEffectSilent(EFFECT_OMERTA)
    -- 2026-09-06: REVERTED -- see incus_cell.lua. Offset 10 was correct all along; the real bug
    -- was CELL_OFFSET itself (7213 -> 7212), which is exactly what put this cell's message on the
    -- real Nyzul "lamp" text (CELL_OFFSET+29=7242) instead of "Spellcasting restriction removed".
    target:messageText(target, zones[target:getZoneID()].text.CELL_OFFSET + 10)
end

