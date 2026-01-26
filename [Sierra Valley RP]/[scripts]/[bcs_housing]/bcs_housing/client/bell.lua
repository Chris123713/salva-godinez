RegisterNetEvent('Housing:client:Bell', function(homeId)
    if CurrentHome and CurrentHome.identifier == homeId then
        SendReactMessage('playSound', {
            src = './sounds/doorbell.ogg',
            volume = 0.5
        })
    end
end)

function RingBell(entity, homeId)
    local coords = GetEntityCoords(cache.ped)
    local entityCoords = GetEntityCoords(entity)
    local heading = GetEntityHeading(cache.ped)
    local targetHeading = GetHeadingFromVector_2d(entityCoords.x - coords.x, entityCoords.y - coords.y)
    local diff = math.abs(heading - targetHeading)

    if diff > 180 then
        diff = 360 - diff
    end

    if diff > 30 then
        TaskTurnPedToFaceEntity(cache.ped, entity, 1000)
        Wait(1000)
    end

    lib.playAnim(cache.ped, "gestures@m@standing@casual", "gesture_hand_down")
    Wait(1000)
    TriggerServerEvent('Housing:server:Bell', homeId)
end
