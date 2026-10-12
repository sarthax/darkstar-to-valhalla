---------------------------------------------------------------------------------------------------
-- func: garden <action> <value> <slot>
-- desc: Debug/test Mog House flowerpots (Mog Safe / Safe 2). Acts on every pot, or only the pot
--       in <slot> if given. You must be inside your Mog House (pots are only ticked there).
--
--   info                list pots: plant, stage, crystals, strength, dried, examined, time to next stage
--   plant <1-8>         clean pot and sow: 1 fruit 2 herb 3 grain 4 vegetable 5 cactus
--                       6 tree cuttings 7 tree saplings 8 wildgrass
--   stage <1-11>        jump to stage (10 = mature, 11 = wilted); timer reset to that stage's duration
--   grow [n]            advance n stages (default 1) using the normal growth logic
--   mature              jump straight to the harvestable stage
--   wilt                jump to wilted
--   ready               make the current stage due now (the next tick advances it)
--   crystal1 <0-8>      set common crystal element (0 none, 1 fire 2 ice 3 wind 4 earth
--                       5 lightning 6 water 7 light 8 dark)
--   crystal2 <0-8>      set second (tree) crystal element
--   strength <0-31>     set hidden plant strength
--   dry <0|1>           set dried flag
--   examined <0|1>      set examined flag
--   results             show what a harvest would currently give (random roll)
--   clean               empty the pot
---------------------------------------------------------------------------------------------------

cmdprops =
{
    permission = 1,
    parameters = "sii"
};

function error(player, msg)
    player:PrintToPlayer(msg);
    player:PrintToPlayer("!garden <info|plant|stage|grow|mature|wilt|ready|crystal1|crystal2|strength|dry|examined|results|clean> {value} {slot}");
end;

function onTrigger(player, action, value, slot)
    if (action == nil) then
        action = "info";
    end

    local result = player:gardenDebug(action, value or 0, slot or -1);
    for line in string.gmatch(result, "[^\n]+") do
        player:PrintToPlayer(line);
    end
end;
