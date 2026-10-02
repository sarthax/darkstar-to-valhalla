---------------------------------------------------------------------------------------------------
-- func: mobskilldiag
-- desc: Prints the targeted mob's skill-related state (skill list mod, TP-use chance mod, TP, HP%,
--       job, pool) so "mob never uses TP moves" can be diagnosed from in-game instead of guessed.
--       Pair with `!tp 3000 <t>` (works on the targeted mob) and watch whether it fires.
---------------------------------------------------------------------------------------------------

cmdprops =
{
    permission = 1,
    parameters = ""
};

function onTrigger(player)
    local mob = player:getCursorTarget();
    if (mob == nil or mob:getObjType() ~= TYPE_MOB) then
        player:PrintToPlayer("Target a mob first.");
        return;
    end
    player:PrintToPlayer(string.format("%s id=%d pool=%d mJob=%d sJob=%d HP%%=%d TP=%d engaged=%s",
        mob:getName(), mob:getID(), mob:getPool(), mob:getMainJob(), mob:getSubJob(), mob:getHPP(),
        mob:getTP(), tostring(mob:getTarget() ~= nil)));
    player:PrintToPlayer(string.format("MOBMOD_SKILL_LIST=%d MOBMOD_TP_USE_CHANCE=%d MOBMOD_SPECIAL_SKILL=%d",
        mob:getMobMod(MOBMOD_SKILL_LIST), mob:getMobMod(MOBMOD_TP_USE_CHANCE), mob:getMobMod(MOBMOD_SPECIAL_SKILL)));
end;
