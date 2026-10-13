-----------------------------------
--  Area: Ru'Lude Gardens
--   NPC: Explorer Moogle
--  Type: Mog Tablets / Super Kupowers (see scripts/globals/mog_tablets.lua)
-- @zone 243
--
-- Events (captures: Veralice 2025-10-27 turn-in, Nowakii 2023-05-13, Raguza 2021-12-19) [C]:
--   10111  turn-in of a found tablet. Client EndPara 2 = "take reward". Reward = Kupofried's Ring + the tablet's item.
--   10109  info menu once all 11 are found. Option 1 = list active powers (update param0 = power bitmask),
--          option 3 = number of tablets found (update param0), option 4 = poll, options > 4 = per-zone "tablet of X was discovered there".
--   10108  first-visit menu (story), 10114 story-only menu [S].
-----------------------------------
package.loaded["scripts/zones/RuLude_Gardens/TextIDs"] = nil;
require("scripts/zones/RuLude_Gardens/TextIDs");
require("scripts/globals/mog_tablets");
-----------------------------------

local function nextPending(player)
    local mask = player:getVar("[MOGTAB]Pending");
    for t = 0, 10 do
        if (bit.band(mask, bit.lshift(1, t)) ~= 0) then return t; end
    end
    return nil;
end

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    MOG_TABLET.tick();
    local t = nextPending(player);
    if (t ~= nil) then
        -- Retail blocks BOTH items while the reward item is already held [W]. The blocking dialog text is not captured: placeholder.
        local reward = MOG_TABLET.TABLETS[t].reward;
        if (player:hasItem(reward)) then
            player:PrintToPlayer("(placeholder) You already have this tablet's reward. Discard it first, kupo.");
        elseif (player:getFreeSlotsCount() < 2) then
            player:messageSpecial(ITEM_CANNOT_BE_OBTAINED, reward);
        else
            player:setLocalVar("MogTabletTurnIn", t + 1);
            -- 8 values exactly as captured for csid 10111; params after the first four are unverified for tablets other than Piety.
            player:startEvent(10111, 0, 4, 2963, 0, 67108863, 455040168, 4095, 131103);
        end
        return;
    end
    if (MOG_TABLET.countFound() >= 11) then
        player:startEvent(10109);
    else
        player:startEvent(10114);
    end
end;

function onEventUpdate(player,csid,option)
    if (csid == 10109) then
        if (option == 1) then
            player:updateEvent(MOG_TABLET.getPowers());          -- [C] 522 for Martial Master+Treasure Hound+Swift Shoes
        elseif (option == 3) then
            player:updateEvent(MOG_TABLET.countFound());         -- [C] param0 = 11
        end
        -- option 4 poll and options > 4 (per-zone list): reply params not decoded yet, no reply sent.
    end
end;

function onEventFinish(player,csid,option)
    if (csid == 10111 and option == 2) then
        local t = player:getLocalVar("MogTabletTurnIn") - 1;
        player:setLocalVar("MogTabletTurnIn", 0);
        local def = MOG_TABLET.TABLETS[t];
        if (def ~= nil and bit.band(player:getVar("[MOGTAB]Pending"), bit.lshift(1, t)) ~= 0
            and player:getFreeSlotsCount() >= 2 and not player:hasItem(def.reward)) then
            player:addItem(MOG_TABLET.KUPOFRIEDS_RING);
            player:messageSpecial(ITEM_OBTAINED, MOG_TABLET.KUPOFRIEDS_RING);
            player:addItem(def.reward);
            player:messageSpecial(ITEM_OBTAINED, def.reward);
            player:setVar("[MOGTAB]Pending", bit.band(player:getVar("[MOGTAB]Pending"), bit.bnot(bit.lshift(1, t))));
        end
    end
end;
