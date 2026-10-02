-----------------------------------------
-- ID: 5433
-- Item: Dusty Elixir
-- Item Effect: Instantly restores 25% of HP and MP -- confirmed via BG Wiki ("Restores 25% HP
-- and MP"). Ported from Topaz's own working scripts/globals/items/dusty_elixir.lua, converted to
-- old-dsp-reference's bare-msgBasic-global convention.
-----------------------------------------
require("scripts/globals/msg");
-----------------------------------------
function onItemCheck(target)
    local result = 0;
    local mHP = target:getMaxHP();
    local cHP = target:getHP();
    local mMP = target:getMaxMP();
    local cMP = target:getMP();

    if (mHP == cHP and mMP == cMP) then
        result = 56; -- Does not let player use item if their hp and mp are full
    end

    return result;
end;

function onItemUse(target)
    -- No combined "recovers HP and MP" message id exists in old-dsp-reference's msg.lua
    -- (grep-verified) -- rather than guess one, send the two real, already-confirmed individual
    -- recovery messages instead (id 24 = recovers HP, matches potion.lua/etc.; id 25 = recovers
    -- MP, matches ether.lua).
    target:messageBasic(24, 0, target:addHP(target:getMaxHP() * .25));
    target:messageBasic(25, 0, target:addMP(target:getMaxMP() * .25));
end;
