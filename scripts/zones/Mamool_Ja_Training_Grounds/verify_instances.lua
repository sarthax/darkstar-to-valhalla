-- verify_instances.lua
-- Diagnostic script for Mamool Ja Training Grounds assault instances
-- Usage: Require this to verify instance structure, then check output

local function verifyInstance(filePath)
    local f = io.open(filePath, "r")
    if not f then
        print("ERROR: Cannot open file: " .. filePath)
        return false
    end

    local content = f:read("*a")
    f:close()

    local issues = {}

    -- Check for required functions
    local requiredFuncs = {
        ["afterInstanceRegister"] = true,
        ["onInstanceCreated"] = true,
        ["onInstanceTimeUpdate"] = true,
        ["onInstanceFailure"] = true,
        ["onInstanceProgressUpdate"] = true,
        ["onInstanceComplete"] = true,
    }

    for funcName, _ in pairs(requiredFuncs) do
        if not content:match("function " .. funcName .. "\\(") then
            table.insert(issues, "MISSING FUNCTION: " .. funcName)
        end
    end

    -- Check for instance:getID() usage (potential crash source)
    if content:match("instance:getID\\(") then
        print("WARNING: Instance uses getID() - verify implementation is safe")
    end

    -- Check for setLocalVar without matching getter
    local localVarSet = content:match("setLocalVar\\(") or 0
    localVarGet = (content:match("getLocalVar\\(") or 0)

    if localVarSet > localVarGet then
        table.insert(issues, "UNBALANCED: setLocalVar(" .. localVarSet .. ") vs getLocalVar(" .. localVarGet .. ")")
    end

    -- Check for instance:setProgress() calls
    local progressCalls = content:gmatch("setProgress\\([^)]+\\)")
    local count = 0
    for _ in progressCalls do
        count = count + 1
    end
    if count > 0 then
        print(string.format("INFO: Mission tracks %d progress items", count))
    end

    -- Check for door prop handling
    if content:match("DOOR_PROPS\\s*=") then
        local props = content:match("%{[^%}]+%}")
        if props and #props > 0 then
            print(string.format("INFO: Door props registered: %d entries",
                #(content:gmatch("%d+")))
        end
    end

    -- Check for mob group usage
    local mobGroup = content:match("MOB_GROUP_%d+")
    if mobGroup then
        print(string.format("INFO: Uses mob group: %s", mobGroup))
    end

    if #issues > 0 then
        for _, issue in ipairs(issues) do
            print("ISSUE: " .. issue)
        end
        return false
    end

    return true
end

-- Verify all instances
local instanceDir = package.searchpath("zones/Mamool_Ja_Training_Grounds/instances", "scripts.path")
local instances, err = os.glob(instanceDir .. "/%.lua")

if not instances then
    print("ERROR: Cannot find instances directory")
else
    print("Mamool Ja Training Grounds Instance Verification Report")
    print("=" * 60)

    local results = {}
    for _, instance in ipairs(instances) do
        -- Extract mission ID from filename (e.g., imperial_agent_rescue.lua -> check mapping)
        -- For now, just verify the file exists and has valid structure

        if verifyInstance(instance) then
            print(string.format("[OK] %s", instance))
            results[instance] = true
        else
            print(string.format("[FAIL] %s", instance))
            results[instance] = false
        end
    end

    -- Generate summary table for Mamool Ja missions
    print("\nMission Mapping:")
    local missionMap = {
        [11] = "imperial_agent_rescue.lua",
        [12] = "preemptive_strike.lua",
        [13] = "sagelord_elimination.lua",
        [14] = "breaking_morale.lua",
    }

    for id, filename in pairs(missionMap) do
        local path = instanceDir .. "/" .. filename
        if results[path] then
            print(string.format("Mission %3d -> %-35s [%s]", id, filename,
                missionMap[id]))
        else
            print(string.format("Mission %3d -> %-35s [NOT VERIFIED]", id, filename))
        end
    end

    -- Zone information
    print("\nZone Information:")
    print("- Zone ID: 66 (Mamool Ja Training Grounds)")
    print("- Entrance Zone: 52 (Babaa'ula)")
    print("- Expected behavior: !warpassault <id> should warp to zone 66, then create instance")
end
