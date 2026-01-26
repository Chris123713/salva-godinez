-- Server utility functions

Utils = {}

-- Debug print helper
function Utils.Debug(...)
    if Config.Debug.Enabled then
        print('^3[sv_nexus_tools]^7', ...)
    end
end

-- Error print helper
function Utils.Error(...)
    print('^1[sv_nexus_tools ERROR]^7', ...)
end

-- Success print helper
function Utils.Success(...)
    print('^2[sv_nexus_tools]^7', ...)
end

-- Generate UUID
function Utils.GenerateUUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- Get player data helper
function Utils.GetPlayer(source)
    return exports.qbx_core:GetPlayer(source)
end

-- Get citizen ID from source
function Utils.GetCitizenId(source)
    local player = Utils.GetPlayer(source)
    return player and player.PlayerData.citizenid or nil
end

-- Check if player has permission
function Utils.HasPermission(source, permission)
    return IsPlayerAceAllowed(source, permission)
end

-- Check if player has job
function Utils.HasJob(source, jobName, minGrade)
    local player = Utils.GetPlayer(source)
    if not player then return false end

    local job = player.PlayerData.job
    if job.name ~= jobName then return false end
    if minGrade and job.grade.level < minGrade then return false end

    return true
end

-- Rate limiting
local RateLimits = {}

function Utils.RateLimitCheck(source, action, cooldownMs)
    local key = tostring(source) .. ':' .. action
    local now = GetGameTimer()

    if RateLimits[key] and (now - RateLimits[key]) < cooldownMs then
        return false, RateLimits[key] + cooldownMs - now
    end

    RateLimits[key] = now
    return true
end

-- Clean up old rate limits periodically
CreateThread(function()
    while true do
        Wait(60000) -- Every minute
        local now = GetGameTimer()
        for key, time in pairs(RateLimits) do
            if (now - time) > 300000 then -- 5 minutes old
                RateLimits[key] = nil
            end
        end
    end
end)

-- Table size helper
function Utils.TableSize(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Safe JSON encode
function Utils.JsonEncode(data)
    local success, result = pcall(json.encode, data)
    return success and result or nil
end

-- Safe JSON decode
function Utils.JsonDecode(str)
    local success, result = pcall(json.decode, str)
    return success and result or nil
end

-- Vector3 from table
function Utils.Vec3FromTable(t)
    if type(t) == 'vector3' then return t end
    if type(t) == 'table' then
        return vector3(t.x or t[1] or 0, t.y or t[2] or 0, t.z or t[3] or 0)
    end
    return vector3(0, 0, 0)
end

-- Table to vector4 (coords + heading)
function Utils.Vec4FromTable(t)
    if type(t) == 'vector4' then return t end
    if type(t) == 'table' then
        return vector4(
            t.x or t[1] or 0,
            t.y or t[2] or 0,
            t.z or t[3] or 0,
            t.w or t[4] or 0
        )
    end
    return vector4(0, 0, 0, 0)
end
