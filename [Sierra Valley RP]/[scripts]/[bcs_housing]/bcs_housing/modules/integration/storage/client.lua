function OpenStorage(data, home)
    if Config.Inventory == "ox_inventory" then
        if home.properties.complex == 'Apartment' then
            local owner = Apartments[home.identifier]:GetApartmentById(LocalPlayer.state.CurrentApartment).owner
            exports.ox_inventory:openInventory('stash', { id = data.identifier, owner = owner })
        else
            exports.ox_inventory:openInventory('stash', data.identifier)
        end
    elseif Config.Inventory == 'qs-inventory' then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", "Stash_" .. data.identifier,
            {
                maxweight = data.weight or Config.FurnitureStorage.weight,
                slots = data.slots or
                    Config.FurnitureStorage.slots
            })
        TriggerEvent("inventory:client:SetCurrentStash", "Stash_" .. data.identifier)
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'lj-inventory' then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", data.identifier,
            {
                maxweight = data.weight or Config.FurnitureStorage.weight,
                slots = data.slots or
                    Config.FurnitureStorage.slots
            })
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "StashOpen", 0.4)
        TriggerEvent("inventory:client:SetCurrentStash", data.identifier)
    elseif Config.Inventory == 'ak47_inventory' then
        -- Add support for ak47_inventory
        exports['ak47_inventory']:OpenInventory({
            identifier = "stash:" .. data.identifier,
            label = "House Stash",
            type = "stash",
            maxWeight = data.weight or Config.FurnitureStorage.weight,
            slots = data.slots or Config.FurnitureStorage.slots,
        })
    elseif Config.Inventory == 'chezza' then
        TriggerEvent("inventory:openHouse", data.owner, data.identifier, "House Stash", data.weight)
    elseif Config.Inventory == 'core_inventory' then
        TriggerServerEvent('core_inventory:server:openInventory', string.sub(data.identifier, 9), "stash")
    elseif Config.Inventory == 'mInventory' or Config.Inventory == 'tgiann' then
        local name = data.identifier
        local maxweight = data.weight or Config.FurnitureStorage.slots
        local slot = data.slots or Config.FurnitureStorage.slots
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', name,
            { maxweight = maxweight, slots = slot })
    else
        TriggerServerEvent('Housing:server:OpenStash', data.identifier, data.weight, data.slots)
    end
end

function StoragePrompt(data)
    CreateThread(function()
        HelpText(true, locale('prompt_open_storage'))
        while inZone do
            Wait(2)
            if IsControlJustReleased(0, 38) then
                HelpText(false)
                data.owner = Homes[data.home].properties.owner
                TriggerEvent('Housing:Storage', data)
                break
            end
        end
    end)
end
