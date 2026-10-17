-----------------------------------
-- Area: Lower Jeuno
-- NPC: Hasim
-- Standard Merchant NPC
-----------------------------------

require("scripts/globals/shop");
package.loaded["scripts/zones/Lower_Jeuno/TextIDs"] = nil;
require("scripts/zones/Lower_Jeuno/TextIDs");

-----------------------------------
-- onTrade Action
-----------------------------------

function onTrade(player,npc,trade)
end; 

-----------------------------------
-- onTrigger Action
-----------------------------------

function onTrigger(player,npc)
    
player:showText(npc,HASIM_SHOP_DIALOG);

stock = {0x1244,930,        -- Scroll of Baraera
     0x123e,930,        -- Scroll of Baraero
     0x1243,3624,        -- Scroll of Barblizzara
     0x123d,3624,        -- Scroll of Barblizzard
     0x1242,1760,        -- Scroll of Barfira
     0x123c,1760,        -- Scroll of Barfire
     0x1245,156,        -- Scroll of Barstonra
     0x123f,156,        -- Scroll of Barstone
     0x1246,5754,        -- Scroll of Barthundra
     0x1240,5754,        -- Scroll of Barthunder
     0x1247,360,        -- Scroll of Barwatera
     0x1241,360,        -- Scroll of Barwater
     0x1208,11200,        -- Scroll of Curaga II
     0x1209,19932,        -- Scroll of Curaga III
     0x1204,23400,        -- Scroll of Cure IV
     0x1248,244,        -- Scroll of Barsleep
     0x1249,400,        -- Scroll of Barpoison
     0x124a,780,        -- Scroll of Barparalyze
     0x124b,2030,        -- Scroll of Barblind
     0x124c,4608,        -- Scroll of Barsilence
     0x124d,15120,        -- Scroll of Barpetrify
     0x124e,9600,        -- Scroll of Barvirus
     0x1256,244,        -- Scroll of Barsleepra
     0x1257,400,        -- Scroll of Barpoisonra
     0x1258,780,        -- Scroll of Barparalyzra
     0x1259,2030,        -- Scroll of Barblindra
     0x125a,4608,        -- Scroll of Barsilencera
     0x122d,32000}        -- Scroll of Protect III
 
showShop(player, STATIC, stock);
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

