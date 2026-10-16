-----------------------------------
-- Geomantic Reservoirs: a GEO who already knows an Indi- spell learns the matching Geo- spell here.
-- Per-zone scripts pass their own text ids and event id (read from the client DAT, they differ per zone).
-- Geo spell id = Indi spell id + 30; scroll item ids are used for the "learns" message only.
-----------------------------------
require("scripts/globals/status");

geomanticReservoir = {};

-- spell name -> {geo spell id, geo scroll item id}
geomanticReservoir.spells =
{
    regen      = {798, 6102}, poison    = {799, 6103}, refresh = {800, 6104}, haste     = {801, 6132},
    str        = {802, 6105}, dex       = {803, 6106}, vit     = {804, 6107}, agi       = {805, 6108},
    int        = {806, 6109}, mnd       = {807, 6110}, chr     = {808, 6111}, fury      = {809, 6112},
    barrier    = {810, 6113}, acumen    = {811, 6114}, fend    = {812, 6115}, precision = {813, 6116},
    voidance   = {814, 6117}, focus     = {815, 6118}, attunement = {816, 6119}, wilt   = {817, 6120},
    frailty    = {818, 6121}, fade      = {819, 6122}, malaise = {820, 6123}, slip      = {821, 6124},
    torpor     = {822, 6125}, vex       = {823, 6126}, languor = {824, 6127}, slow      = {825, 6128},
    paralysis  = {826, 6129}, gravity   = {827, 6130},
};

-- cfg = {spell = "regen", event = 15000, learns = <text id>, nothing = <text id>}
function geomanticReservoir.onTrigger(player, cfg)
    local s = geomanticReservoir.spells[cfg.spell];
    if (player:getMainJob() == JOBS.GEO and not player:hasSpell(s[1]) and player:hasSpell(s[1] - 30)) then
        player:startEvent(cfg.event, math.random(230, 300));
    else
        player:messageSpecial(cfg.nothing);
    end
end

function geomanticReservoir.onEventFinish(player, csid, option, cfg)
    if (csid == cfg.event) then
        local s = geomanticReservoir.spells[cfg.spell];
        if (not player:hasSpell(s[1])) then
            player:addSpell(s[1], true);
            player:messageSpecial(cfg.learns, s[2]);
        end
    end
end
