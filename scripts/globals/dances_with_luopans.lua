-----------------------------------
-- Dances with Luopans (Geomancer unlock) - Ceizak / Yahse resting step
-- Quest: ADOULIN log, DANCES_WITH_LUOPANS. Sylvie, Western Adoulin.
-- Progress is char var "DwL_Prog": 0 = find the locus, 1 = ready to return.
-- Text ids are client-verified per zone (dialog.yml), kept local on purpose.
-----------------------------------
require("scripts/globals/status");
require("scripts/globals/keyitems");
require("scripts/globals/quests");

DWL = {};

DWL.text =
{
    [261] = {uncanny = 8025, course = 8026, warmth = 8027}, -- Ceizak Battlegrounds
    [260] = {uncanny = 7858, course = 7859, warmth = 7860}, -- Yahse Hunting Grounds
};

DWL.MIN_WAIT = 9;   -- 3 healing ticks
DWL.MAX_WAIT = 480; -- 8 minutes

function DWL.active(player)
    return player:hasKeyItem(LUOPAN) and player:getVar("DwL_Prog") == 0;
end

function DWL.onLocusEnter(player)
    local t = DWL.text[player:getZoneID()];
    if (t ~= nil and DWL.active(player)) then
        player:messageSpecial(t.uncanny);
        player:setLocalVar("DwL_Locus", 1);
    end
end

function DWL.onLocusLeave(player)
    player:setLocalVar("DwL_Locus", 0);
    player:setLocalVar("DwL_RestUntil", 0);
end

-- called from the healing effect gain
function DWL.onHealingGain(player)
    local t = DWL.text[player:getZoneID()];
    if (t ~= nil and player:getLocalVar("DwL_Locus") == 1 and DWL.active(player)) then
        player:messageSpecial(t.course);
        player:setLocalVar("DwL_RestUntil", os.time() + math.random(DWL.MIN_WAIT, DWL.MAX_WAIT));
    end
end

-- called from every healing tick
function DWL.onHealingTick(player)
    local rest = player:getLocalVar("DwL_RestUntil");
    local t = DWL.text[player:getZoneID()];
    if (rest > 0 and t ~= nil and player:getLocalVar("DwL_Locus") == 1) then
        if (os.time() >= rest) then
            player:setLocalVar("DwL_RestUntil", 0);
            if (DWL.active(player)) then
                player:messageSpecial(t.warmth);
                player:setVar("DwL_Prog", 1);
            end
        end
    end
end

function DWL.onHealingLose(player)
    player:setLocalVar("DwL_RestUntil", 0);
end
