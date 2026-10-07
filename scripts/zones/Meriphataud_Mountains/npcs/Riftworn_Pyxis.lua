-----------------------------------
-- Area: Meriphataud Mountains (119)
--  NPC: Riftworn Pyxis (Voidwatch) -- csid = rift csid + 3. FIRST-PASS, untested.
-- Options per retail capture: 9 = done, 10 = take items. Mapping of 9/10 to
-- relinquish/obtain is inferred (FLAGGED).
-- Message ids = z95 + 3346 [V: z119 dialog.yml text-checked].
-----------------------------------
require("scripts/globals/voidwatch");

local PYXIS_FIRST = 17265318;
local VW_NOT_ELIGIBLE = 11834;
local VW_ALL_OBTAINED = 11835;
local VW_OBTAINS_ITEM = 11839;
local VW_RELINQUISHED = 11844;

function onTrade(player,npc,trade) end;

function onTrigger(player,npc)
    local csid = 6003 + (npc:getID() - PYXIS_FIRST);
    if (npc:getLocalVar("ELIG" .. player:getID()) ~= 1) then
        player:messageSpecial(VW_NOT_ELIGIBLE);
        return;
    end
    if (npc:getLocalVar("TAKEN" .. player:getID()) == 1) then
        player:messageSpecial(VW_ALL_OBTAINED);
        return;
    end
    local it = vwPyxisItems(npc);
    player:startEvent(csid, it[1], it[2], it[3], it[4], it[5], it[6], it[7], it[8]);
end;

function onEventUpdate(player,csid,option) end;

function onEventFinish(player,csid,option,npc)
    if (csid < 6003 or csid > 6005) then return; end
    local npcid = PYXIS_FIRST + (csid - 6003);
    local pyxis = GetNPCByID(npcid);
    if (pyxis == nil or pyxis:getLocalVar("ELIG" .. player:getID()) ~= 1) then return; end
    if (option == 10) then
        for _, item in ipairs(vwPyxisItems(pyxis)) do
            if (item ~= 0 and player:addItem(item, 1)) then
                player:messageSpecial(VW_OBTAINS_ITEM, item);
            end
        end
        pyxis:setLocalVar("TAKEN" .. player:getID(), 1);
    elseif (option == 9) then
        pyxis:setLocalVar("TAKEN" .. player:getID(), 1);
        player:messageSpecial(VW_RELINQUISHED);
    end
end;
