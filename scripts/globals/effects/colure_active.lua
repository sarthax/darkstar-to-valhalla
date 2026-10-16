-----------------------------------
-- EFFECT_COLURE_ACTIVE (slice run-geo-jobs)
-- Owns an Indi/Geo aura. The area tick lives in C++ (CStatusEffectContainer::HandleAura).
-- power = visual effect id, subid = granted effect, subpower = its potency, tier = 0 allies / 1 enemies
-- On a Luopan the effect doubles as its lifetime (duration) and HP decay (REGEN_DOWN per tick).
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

function onEffectGain(target,effect)
end;

function onEffectTick(target,effect)
    if (target:getObjType() == TYPE_PET and target:getPetID() == GEOMANCER.LUOPAN_PETID) then
        local drain = target:getMod(MOD_REGEN_DOWN);
        if (drain > 0) then
            if (target:getHP() <= drain) then
                local master = target:getMaster();
                if (master ~= nil) then
                    master:despawnPet();
                end
            else
                target:delHP(drain);
            end
        end
    end
end;

function onEffectLose(target,effect)
    if (target:getObjType() == TYPE_PET and target:getPetID() == GEOMANCER.LUOPAN_PETID) then
        local master = target:getMaster();
        if (master ~= nil) then
            master:despawnPet();
        end
    end
end;
