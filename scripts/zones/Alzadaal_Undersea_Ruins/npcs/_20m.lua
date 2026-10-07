-----------------------------------
-- Area: Alzadaal Undersea Ruins
-- Door: Runic Seal
-- !pos 125 -2 20 72
-----------------------------------
-- DSP-PORT-MERGE: this is DSP's own real, already-working _20m.lua (kept as the base -- it's a
-- mature, complete implementation, not a stub), with exactly 2 real bug fixes cherry-picked from
-- Topaz's independently-rewritten version of the same file. Everything else in Topaz's rewrite was
-- deliberately NOT ported -- see MERGE_DECISIONS.md for the full diff reasoning, including one
-- place where Topaz's rewrite introduced a real operator-precedence regression that DSP's own
-- original code gets right (`not (A and B)` vs `(not A) and B`) -- DSP's original stays.
-----------------------------------

package.loaded["scripts/zones/Alzadaal_Undersea_Ruins/TextIDs"] = nil;
-----------------------------------

require("scripts/globals/keyitems");
require("scripts/globals/missions");
require("scripts/globals/besieged");
require("scripts/zones/Alzadaal_Undersea_Ruins/TextIDs");

-----------------------------------
-- onTrade Action
-----------------------------------

function onTrade(player,npc,trade)
end;

-----------------------------------
-- onTrigger Action
-----------------------------------

function onTrigger(player,npc)
    -- See notes below
    player:setVar("NyzulLoopGuard",0); -- Reset Latch 1
    player:setVar("NyzulReady",0); -- Reset Latch 2
    player:setVar("HeroinesHoldfast",0); -- clear a stale flag from a cancelled earlier attempt

    if (player:getCurrentMission(TOAU) == PATH_OF_DARKNESS and player:hasKeyItem(NYZUL_ISLE_ROUTE) and player:getVar("AhtUrganStatus") == 1) then
        player:setVar("PathOfDarkness",1);
        player:startEvent(0x0195, 58, -6, 0, 99, 5, 0);
    elseif (player:getCurrentMission(TOAU) == NASHMEIRAS_PLEA and player:hasKeyItem(MYTHRIL_MIRROR) and player:getVar("AhtUrganStatus") == 1) then
        player:setVar("NashmeirasPlea",1);
        player:startEvent(0x0195, 59, -10, 0, 99, 5, 0);
    elseif (player:hasKeyItem(NYZUL_ISLE_ASSAULT_ORDERS) and (player:getCurrentAssault() == 51 or player:getCurrentAssault() == 52)) then
        local assaultid = player:getCurrentAssault();
        local recommendedLevel = getRecommendedAssaultLevel(assaultid);
        local armband = 0;
        if (player:hasKeyItem(ASSAULT_ARMBAND)) then
            armband = 1;
        end
        player:startEvent(0x0195, assaultid, -4, 0, recommendedLevel, 5, armband);
    -- Heroines' Holdfast entry (capture #237): Athena Orb (item 3557) held. startEvent params are the
    -- capture's real 8-value 0x034 for csid 405 (0, -66, 1757, 0, 5, 1, 0, 11); -66 selects the mission name.
    elseif (player:hasItem(3557)) then
        player:setVar("HeroinesHoldfast",1);
        player:startEvent(0x0195, 0, -66, 1757, 0, 5, 1, 0, 11);
    -- DSP-PORT-MERGE (real bug fix, ported from Topaz's rewrite): a character holding a stale
    -- NYZUL_ISLE_ASSAULT_ORDERS (left over from an earlier run, with their real "current assault"
    -- slot since overwritten/cleared by entering a DIFFERENT assault instance elsewhere -- only one
    -- can be active on a character at a time) used to fall through to this branch unconditionally
    -- and reach player:createInstance(0, 77) -- a real, invalid instance id with no matching
    -- instance_list.sql row, landing the player at raw (0,0,0), out of bounds. The added
    -- getCurrentAssault()==51-or-52 check above scopes that branch to real Nyzul Isle assault ids;
    -- this new branch catches the stale-key-item case instead of falling through to "else" and
    -- clears it, matching Topaz's confirmed live fix.
    elseif (player:hasKeyItem(NYZUL_ISLE_ASSAULT_ORDERS)) then
        player:delKeyItem(NYZUL_ISLE_ASSAULT_ORDERS);
        player:messageSpecial(NOTHING_HAPPENS);
    else
        player:messageSpecial(NOTHING_HAPPENS);
    end
end;

-----------------------------------
-- onEventUpdate
-----------------------------------

function onEventUpdate(player,csid,option,target)
    -- printf("UPDATE CSID: %u",csid);
    -- printf("UPDATE RESULT: %u",option);

    if(not(csid == 0x0195)) then
        return;
    end

    -- Begin Ugly Hack
    --
    -- For some currently unknown reason, the Nyzul event can
    -- spam event updates uncontrollably. Until we can figure
    -- out why, I used a double lock to hack around it. The
    -- first latch is auto set here, which suppresses future
    -- updates which the instance is initialized. The 2nd latch
    -- is set after the instance is created. Then we use that
    -- to force terminate the event so that we can go into the
    -- instance successfully.
    local nyzulReady = player:getVar("NyzulReady");

    if(player:getVar("NyzulReady")==1) then -- Latch 2
        player:updateEvent(0x0195,3,3,3,3,3,3,3); -- Force terminate the event
        return;
    elseif(player:getVar("NyzulLoopGuard")==1) then
        return; -- Suppress Update Spam
    else
        player:setVar("NyzulLoopGuard",1); -- Latch 1
    end
    -- End Ugly Hack

    local assaultid = player:getCurrentAssault();

    local cap = bit.band(option, 0x03);
    if (cap == 0) then
        cap = 99;
    elseif (cap == 1) then
        cap = 70;
    elseif (cap == 2) then
        cap = 60;
    else
        cap = 50;
    end

    player:setVar("AssaultCap", cap);

    local pathOfDarkness = player:getVar("PathOfDarkness");
    local nashmeirasPlea = player:getVar("NashmeirasPlea");
    local heroines = player:getVar("HeroinesHoldfast");

    if(pathOfDarkness == 1) then
        local party = player:getParty();

        if (party ~= nil) then
            for i,v in ipairs(party) do
                if (v:getID() ~= player:getID()) then
                    if (v:hasKeyItem(NYZUL_ISLE_ROUTE) == false and v:hasCompletedMission(TOAU, PATH_OF_DARKNESS) == false) then
                        player:messageText(target,MEMBER_NO_REQS, false);
                        player:instanceEntry(target,1);
                        return;
                    elseif (v:getZone() == player:getZone() and v:checkDistance(player) > 50) then
                        player:messageText(target,MEMBER_TOO_FAR, false);
                        player:instanceEntry(target,1);
                        return;
                    end
                end
            end
        end

        player:createInstance(58, 77);
    elseif(nashmeirasPlea == 1) then
        local party = player:getParty();

        if (party ~= nil) then
            for i,v in ipairs(party) do
                if (v:getID() ~= player:getID()) then
                    if (v:hasKeyItem(MYTHRIL_MIRROR) == false and v:hasCompletedMission(TOAU, NASHMEIRAS_PLEA) == false) then
                        player:messageText(target,MEMBER_NO_REQS, false);
                        player:instanceEntry(target,1);
                        return;
                    elseif (v:getZone() == player:getZone() and v:checkDistance(player) > 50) then
                        player:messageText(target,MEMBER_TOO_FAR, false);
                        player:instanceEntry(target,1);
                        return;
                    end
                end
            end
        end

        player:createInstance(59, 77);
    elseif (heroines == 1) then
        local party = player:getParty();

        if (party ~= nil) then
            for i,v in ipairs(party) do
                if (v:getID() ~= player:getID() and v:getZone() == player:getZone() and v:checkDistance(player) > 50) then
                    player:messageText(target,MEMBER_TOO_FAR, false);
                    player:instanceEntry(target,1);
                    return;
                end
            end
        end

        player:createInstance(80, 77);
    else
        local party = player:getParty();

        if (party ~= nil) then
            for i,v in ipairs(party) do
                if (v:getID() ~= player:getID()) then
                    if (not (v:hasKeyItem(NYZUL_ISLE_ASSAULT_ORDERS) and v:getCurrentAssault() == assaultid)) then
                        print("NO REQS");
                        player:messageText(target,MEMBER_NO_REQS, false);
                        player:instanceEntry(target,1);
                        return;
                    elseif (v:getZone() == player:getZone() and v:checkDistance(player) > 50) then
                        player:messageText(target,MEMBER_TOO_FAR, false);
                        player:instanceEntry(target,1);
                        return;
                    end
                end
            end
        end

        player:createInstance(player:getCurrentAssault(), 77);
    end

end;

-----------------------------------
-- onEventFinish
-----------------------------------

function onEventFinish(player,csid,option,target)
    -- printf("FINISH CSID: %u",csid);
    -- printf("FINISH RESULT: %u",option);

    if (csid == 0x195 and option == 1073741824 and player:getVar("NyzulReady") == 1) then
        player:startEvent(0x74, 2); -- This means the event was force terminated. Loop into the entrance animation.
    elseif (csid == 0x74 or (csid == 0x195 and option == 4) and not(option == 1073741824)) then
        player:setPos(0,0,0,0,77);
    end
end;

-----------------------------------
-- onInstanceLoaded
-----------------------------------

function onInstanceCreated(player,target,instance)
    local pathOfDarkness = player:getVar("PathOfDarkness");
    local nashmeirasPlea = player:getVar("NashmeirasPlea");
    local heroines = player:getVar("HeroinesHoldfast");

    if (instance) then
        if (pathOfDarkness == 1) then
            player:setVar("PathOfDarkness", 0);
            player:delKeyItem(NYZUL_ISLE_ROUTE);
        elseif (nashmeirasPlea == 1) then
            player:setVar("NashmeirasPlea", 0);
            player:delKeyItem(MYTHRIL_MIRROR);
        elseif (heroines == 1) then
            -- Athena Orb is consumed on entry; explicit container arg is required by DSP's delItem binding
            player:setVar("HeroinesHoldfast", 0);
            player:delItem(3557, 1, 0);
        else
            -- besieged.lua assaultLevels is a ceiling: AssaultCap may only cap LOWER than the designed target
            instance:setLevelCap(math.min(player:getVar("AssaultCap"), getRecommendedAssaultLevel(player:getCurrentAssault())));
            player:setVar("AssaultCap", 0);
            player:delKeyItem(NYZUL_ISLE_ASSAULT_ORDERS);
            player:delKeyItem(ASSAULT_ARMBAND);
        end

        player:setInstance(instance);
        player:instanceEntry(target,4);

        -- DSP-PORT-MERGE (real bug fix, found while diffing against Topaz's rewrite): `party` was
        -- referenced here without ever being declared in this function -- an undefined global reads
        -- as nil in Lua, so `party ~= nil` was always false and this entire party-notification block
        -- (moving party members into the instance, clearing their key items) never actually ran.
        -- Confirmed as a real, currently-live bug in this exact file, not a Topaz-side invention.
        local party = player:getParty();
        if (party ~= nil) then
            for i,v in ipairs(party) do
                if v:getID() ~= player:getID() and v:getZone() == player:getZone() then
                    v:setInstance(instance);
                    v:startEvent(0x74, 2);

                    if (pathOfDarkness == 1) then
                        v:delKeyItem(NYZUL_ISLE_ROUTE);
                    elseif (nashmeirasPlea == 1) then
                        v:delKeyItem(MYTHRIL_MIRROR);
                    else
                        v:delKeyItem(NYZUL_ISLE_ASSAULT_ORDERS);
                    end
                end
            end
        end
    else
        player:messageText(target,CANNOT_ENTER, false);
        player:instanceEntry(target,3);
    end

    -- EventUpdate Hack: 2nd latch
    player:setVar("NyzulReady",1);
end;
