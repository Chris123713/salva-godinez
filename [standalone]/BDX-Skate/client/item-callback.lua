--------------------------------------
-- Skateboard Item Callback for ox_inventory
--------------------------------------

-- Register the skateboard item usage
exports('skateboard', function(data, slot)
    local playerPed = PlayerPedId()

    -- Check if player is in a vehicle
    if IsPedInAnyVehicle(playerPed, false) then
        lib.notify({
            title = 'Skateboard',
            description = 'You cannot use a skateboard in a vehicle',
            type = 'error'
        })
        return
    end

    -- Trigger the skateboard start event
    TriggerEvent('bodhix-skating:client:start', data)

    if Config.Debug then
        print('^2[BDX-Skate]^7 Skateboard item used')
    end
end)

-- Alternative registration method if the above doesn't work
CreateThread(function()
    Wait(1000) -- Wait for ox_inventory to load

    if GetResourceState('ox_inventory') == 'started' then
        exports.ox_inventory:registerHook('useItem', function(payload)
            if payload.name == 'skateboard' then
                local playerPed = PlayerPedId()

                if IsPedInAnyVehicle(playerPed, false) then
                    lib.notify({
                        title = 'Skateboard',
                        description = 'You cannot use a skateboard in a vehicle',
                        type = 'error'
                    })
                    return false
                end

                TriggerEvent('bodhix-skating:client:start', payload)

                if Config.Debug then
                    print('^2[BDX-Skate]^7 Skateboard item used via hook')
                end

                return true
            end
        end, {
            print = false,
            itemFilter = {
                skateboard = true
            }
        })
    end
end)
