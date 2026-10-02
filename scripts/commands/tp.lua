---------------------------------------------------------------------------------------------------
-- func: tp <amount> <player>
-- desc: Sets a players tp (or the GM's currently targeted mob if the name isn't a player). If they have a pet, also sets pet tp.
---------------------------------------------------------------------------------------------------

cmdprops =
{
    permission = 1,
    parameters = "is"
};

function error(player, msg)
    player:PrintToPlayer(msg);
    player:PrintToPlayer("!tp <amount> {player}");
end;

function onTrigger(player, tp, target)

    -- validate amount
    if (tp == nil or tonumber(tp) == nil) then
        error(player, "You must provide an amount.");
        return;
    elseif (tp < 0) then
        error(player, "Invalid amount.");
        return;
    end

    -- validate target
    local targ;
    if (target == nil) then
        -- 2026-09-19: bare `!tp 3000` used to always hit the GM (no feedback, mob TP never changed).
        -- If a mob is targeted, apply to it instead; otherwise fall back to self as before.
        targ = player;
        local cursor = player:getCursorTarget();
        if (cursor ~= nil and cursor:getObjType() == TYPE_MOB) then
            targ = cursor;
        end
    else
        targ = GetPlayerByName(target);
        if (targ == nil) then
            -- 2026-09-19: not a player name -> fall back to whatever the GM has targeted (mobs
            -- included). Before this, `!tp 3000 <t>` on a mob just errored, so mob TP could never be
            -- raised from the GM command.
            local cursor = player:getCursorTarget();
            if (cursor ~= nil and cursor:getObjType() ~= TYPE_NPC) then
                targ = cursor;
            end
        end
        if (targ == nil) then
            error(player, string.format( "Player named '%s' not found!", target ) );
            return;
        end
    end

    -- set tp
    targ:setTP( tp );
    local pet = targ:getPet();
    if (pet ~= nil) then
        pet:setTP( tp );
    end
    if(targ:getID() ~= player:getID()) then
        player:PrintToPlayer(string.format("Set %s's TP to %i.", targ:getName(), targ:getTP()));
    end
end;