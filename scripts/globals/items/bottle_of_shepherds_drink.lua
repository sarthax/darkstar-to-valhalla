-----------------------------------
-- ID: 5396
-- Item: bottle_of_shepherds_drink
-- Item Effect: Instantly restores 50% of a pet's HP -- confirmed via both the real in-game item
-- description ("This medicine instantly restores a pet's HP") and BG Wiki ("Restores 50% HP").
-- API pattern (hasPet check, addHP, messageBasic) matches Topaz's own real, already-working
-- scripts/globals/items/bottle_of_dawn_mulsum.lua (a Nyzul Isle reward with the same real mechanic).
-----------------------------------
require("scripts/globals/settings")
require("scripts/globals/msg")
-----------------------------------
function onItemCheck(target)
    if (not target:hasPet()) then
        return msgBasic.REQUIRES_A_PET
    end
    return 0
end

function onItemUse(target)
    local pet = target:getPet()
    local totalHP = (pet:getMaxHP()/100)*50

    pet:addHP(totalHP)
    -- 2026-09-14: msgBasic.RECOVERS_HP doesn't exist in old-dsp-reference's msg.lua (grep-verified)
    -- -- corrected to message id 24, the same "recovers HP" id every other real HP-recovery item in
    -- this codebase uses (potion.lua, hi-potion.lua, and the sibling pet-heal item
    -- bottle_of_dawn_mulsum.lua this file's own header cites as precedent).
    pet:messageBasic(24, 0, totalHP)
end

