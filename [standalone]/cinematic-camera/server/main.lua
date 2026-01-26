-- Server-side for cinematic camera
-- Currently minimal, but can be extended for permissions, logging, etc.

-- Optional: Create useable camera item if enabled
if Config and Config.CameraItem and Config.CameraItem.enabled then
    exports.qbx_core:CreateUseableItem(Config.CameraItem.itemName, function(source)
        -- Check if player is police - if so, don't trigger cinematic camera
        -- Let rcore_police handle it instead
        local Player = exports.qbx_core:GetPlayer(source)
        if Player and Player.PlayerData and Player.PlayerData.job then
            local jobName = string.lower(Player.PlayerData.job.name or '')
            -- Check for common police job names
            if jobName == 'police' or jobName == 'sheriff' or jobName == 'fib' or jobName == 'state' then
                -- Don't trigger cinematic camera for police - let rcore_police handle it
                return
            end
        end
        TriggerClientEvent('cinematic-camera:client:toggle', source)
    end)
end

