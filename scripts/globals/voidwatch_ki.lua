-----------------------------------
-- Voidwatch: extra key item spoils beyond cfg.keyitem (vwOnKill grants one).
-- Same per-member roll as vwOnKill; the base chance is [D] (sources say "possible spoil", no rate).
-----------------------------------
require("scripts/globals/status");

function vwExtraKeyItem(player, mob, ki, msgid, chance)
    for _, m in pairs(player:getAlliance()) do
        if (m:isPC() and m:getZoneID() == mob:getZoneID() and not m:hasKeyItem(ki) and math.random() < chance) then
            m:addKeyItem(ki);
            m:messageSpecial(msgid, ki);
        end
    end
end
