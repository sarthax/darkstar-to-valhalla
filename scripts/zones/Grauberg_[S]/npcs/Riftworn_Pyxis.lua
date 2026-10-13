-----------------------------------
-- Area: Grauberg_[S] (89)
--  NPC: Riftworn Pyxis (Voidwatch) -- Ocythoe base build; csid = rift csid + 3 [V events.yml]. FIRST-PASS, untested.
-- Options per retail capture: 9 = done, 10 = take items (mapping inferred, flagged).
-- Message ids = Valkurm z103 ids -3033, text-matched in this zone's dialog.yml [V].
-----------------------------------
require("scripts/globals/voidwatch");

local PYXIS_FIRST = 17142621;
local VW_NOT_ELIGIBLE = 8513;
local VW_ALL_OBTAINED = 8514;
local VW_OBTAINS_ITEM = 8518;
local VW_RELINQUISHED = 8523;

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
    if (vwPyxisTake(player, pyxis, csid, option, VW_OBTAINS_ITEM)) then
        return;
    elseif (option == 9) then
        pyxis:setLocalVar("TAKEN" .. player:getID(), 1);
        player:messageSpecial(VW_RELINQUISHED);
    end
end;
