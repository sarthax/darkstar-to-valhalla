-----------------------------------------
-- ID: 15533
-- Item: Chocobo Whistle
-- 
-----------------------------------------
require("scripts/globals/status");

-----------------------------------------
-- OnItemCheck
-----------------------------------------

function onItemCheck(target)
    return target:canUseChocobo();
end;

-----------------------------------------
-- OnItemUse
-----------------------------------------

function onItemUse(target)
    local mine = target:getFieldChocobo();
    if (mine ~= nil and mine.minutes > 0) then
        -- registered chocobo: its own riding time (minutes) and speed (read in CBattleEntity::GetSpeed), subpower 0x40
        target:addStatusEffectEx(EFFECT_MOUNTED,EFFECT_MOUNTED,0,0,mine.minutes * 60,0,0x40,0,true);
    elseif (target:getMainLvl() >= 20) then
        target:addStatusEffectEx(EFFECT_MOUNTED,EFFECT_MOUNTED,0,0,1800,true);
    else
        target:addStatusEffectEx(EFFECT_MOUNTED,EFFECT_MOUNTED,0,0,900,true);
    end
end;
