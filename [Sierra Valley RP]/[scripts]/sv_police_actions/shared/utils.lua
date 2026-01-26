-- Shared utility functions

---@param jobs table List of job names
---@param playerJob string Player's current job name
---@return boolean
function IsPoliceJob(jobs, playerJob)
    for _, job in ipairs(jobs) do
        if job == playerJob then
            return true
        end
    end
    return false
end

---@param entity number Entity handle
---@return number|nil Server ID of player, or nil if not a player
function GetPlayerServerIdFromEntity(entity)
    if not DoesEntityExist(entity) then return nil end
    if not IsPedAPlayer(entity) then return nil end

    local playerIndex = NetworkGetPlayerIndexFromPed(entity)
    if playerIndex == -1 then return nil end

    return GetPlayerServerId(playerIndex)
end
