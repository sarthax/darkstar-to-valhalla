-----------------------------------
-- 
-- Zone: Residential_Area
-- 
-----------------------------------

require("scripts/globals/settings");
package.loaded["scripts/zones/Residential_Area/TextIDs"] = nil;
require("scripts/zones/Residential_Area/TextIDs");

-- Home-nation city zones -> nation + 2F unlock cutscene. Each cs is the event in that zone's Mog House Moogle
-- entity that contains "enjoy your new floor, kupo!" (FFXI-EventsDump); Windurst Walls (547) also matches capture 2021-03-01.
MOGHOUSE_2F_UNLOCK_ZONES =
{
    [230] = {nation = 0, cs = 3535}, [231] = {nation = 0, cs = 904}, [232] = {nation = 0, cs = 820},
    [234] = {nation = 1, cs = 610},  [235] = {nation = 1, cs = 604}, [236] = {nation = 1, cs = 456},
    [238] = {nation = 2, cs = 1086}, [239] = {nation = 2, cs = 547}, [240] = {nation = 2, cs = 903}, [241] = {nation = 2, cs = 885},
};

-----------------------------------
--  onInitialize
-----------------------------------

function onInitialize(zone)
end;

-----------------------------------
-- onZoneIn
-----------------------------------

function onZoneIn(player,prevZone)
    local cs = -1;

    player:setVar("PlayerMainJob",player:getMainJob());
    player:eraseStatusEffect(true);
    player:setPos(0,0,0,192);

    -- Unlock Mog House 2F once all three home-nation Mog House quests are done
    -- mhflag: 0x01 SDO / 0x02 BAS / 0x04 WIN exit quests, 0x20 2F unlocked, 0x40 on 2F,
    --         0x80/0x100 2F style (0 SDO, 1 BAS, 2 WIN, 3 Mog Patio)
    local mhflag = player:moghouseFlag();
    if (ENABLE_MOG_HOUSE_2F == 1 and bit.band(mhflag, 0x07) == 0x07 and bit.band(mhflag, 0x60) == 0) then
        local nationOfZone = MOGHOUSE_2F_UNLOCK_ZONES[player:getZoneID()];
        if (nationOfZone ~= nil and nationOfZone.nation == player:getNation()) then
            player:moghouseFlag(0x20 + 0x80 * player:getNation()); -- unlock + default nation style
                        if (nationOfZone.cs ~= nil) then
                cs = nationOfZone.cs;
            end
        end
    end

    return cs;
end;

-----------------------------------
-- onRegionEnter          
-----------------------------------

function onRegionEnter(player,region)
end;

-----------------------------------
-- onEventUpdate
-----------------------------------

function onEventUpdate(player,csid,option)
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);
end;

-----------------------------------
-- onEventFinish
-----------------------------------

function onEventFinish(player,csid,option)
    -- printf("CSID: %u",csid);
    -- printf("RESULT: %u",option);
end;

