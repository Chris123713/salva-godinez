--[[
    CLIENT-SIDE SOUND SYSTEM

    Manages all elevator sound effects with 3D positional audio support
]]

-- Initialize sound system
CreateThread(function()
    Wait(1000)
    if Config.Sounds.enabled then
        SendNUIMessage({
            action = 'initSounds',
            sounds = {
                ding = Config.Sounds.ding,
                doorOpen = Config.Sounds.doorOpen,
                doorClose = Config.Sounds.doorClose,
                movement = Config.Sounds.movement
            },
            volume = Config.Sounds.volume
        })
    end
end)

-- Play elevator sound with optional 3D positioning
function PlayElevatorSound(soundName, coords)
    if not Config.Sounds.enabled then return end

    local volume = Config.Sounds.volume

    -- Calculate 3D volume based on distance
    if Config.Sounds.use3D and coords then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - coords)

        -- Don't play if too far away
        if distance > Config.Sounds.maxDistance then
            return
        end

        -- Calculate volume falloff (linear)
        local volumeMultiplier = 1.0 - (distance / Config.Sounds.maxDistance)
        volume = Config.Sounds.volume * volumeMultiplier
    end

    SendNUIMessage({
        action = 'playSound',
        sound = soundName,
        volume = volume
    })
end

-- Play looping movement sound during elevator travel
function PlayMovementLoop(duration, coords)
    if not Config.Sounds.enabled then return end

    local volume = Config.Sounds.volume

    -- Calculate 3D volume
    if Config.Sounds.use3D and coords then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - coords)

        if distance > Config.Sounds.maxDistance then
            return
        end

        local volumeMultiplier = 1.0 - (distance / Config.Sounds.maxDistance)
        volume = Config.Sounds.volume * volumeMultiplier
    end

    SendNUIMessage({
        action = 'playLoopingSound',
        sound = 'movement',
        duration = duration,
        volume = volume
    })
end

-- Stop all elevator sounds
function StopAllElevatorSounds()
    SendNUIMessage({
        action = 'stopAllSounds'
    })
end

print("^2[Custom Elevator]^7 Sound system loaded")
