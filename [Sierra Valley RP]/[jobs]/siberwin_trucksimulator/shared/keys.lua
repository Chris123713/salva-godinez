Keys = {}

local function GetKeyScript()
    if not Config.VehicleKeys or not Config.VehicleKeys.enabled then
        return false
    end
    
    local script = Config.VehicleKeys.script
    
    if script == 'auto' then
        if GetResourceState('qbx-vehiclekeys') == 'started' then
            return 'qbx-vehiclekeys'
        elseif GetResourceState('qb-vehiclekeys') == 'started' then
            return 'qb-vehiclekeys'
        elseif GetResourceState('wasabi_carlock') == 'started' then
            return 'wasabi_carlock'
        elseif GetResourceState('cd_garage') == 'started' then
            return 'cd_garage'
        elseif GetResourceState('qs-vehiclekeys') == 'started' then
            return 'qs-vehiclekeys'
        elseif GetResourceState('vehicles_keys') == 'started' then
            return 'vehicles_keys'
        end
        return false
    end
    
    return script
end

function Keys.GiveKeys(vehicle, plate)
    if not Config.VehicleKeys or not Config.VehicleKeys.enabled or not Config.VehicleKeys.giveKeysOnJobStart then
        SetVehicleDoorsLocked(vehicle, 1)
        return true
    end
    
    if not vehicle or not DoesEntityExist(vehicle) then
        return false
    end
    
    plate = plate or GetVehicleNumberPlateText(vehicle)
    local keyScript = GetKeyScript()
    
    if not keyScript then
        SetVehicleDoorsLocked(vehicle, 1)
        return true
    end
    
    if keyScript == 'qbx-vehiclekeys' then
        local success = pcall(function()
            exports['qbx-vehiclekeys']:GiveKeys(plate)
        end)
        
        if success then
            TriggerEvent('qbx-vehiclekeys:client:AddKeys', plate)
            return true
        else
            SetVehicleDoorsLocked(vehicle, 1)
            return false
        end
        
    elseif keyScript == 'qb-vehiclekeys' then
        local success = pcall(function()
            exports['qb-vehiclekeys']:addNoLockVehicles(GetEntityModel(vehicle))
        end)
        
        TriggerEvent('vehiclekeys:client:SetOwner', plate)
        return true
        
    elseif keyScript == 'wasabi_carlock' then
        local success = pcall(function()
            exports.wasabi_carlock:GiveKey(plate)
        end)
        return success
        
    elseif keyScript == 'cd_garage' then
        TriggerEvent('cd_garage:AddKeys', plate)
        return true
        
    elseif keyScript == 'qs-vehiclekeys' then
        local model = GetEntityModel(vehicle)
        local success = pcall(function()
            exports['qs-vehiclekeys']:GiveKeys(plate, model)
        end)
        return success
        
    elseif keyScript == 'vehicles_keys' then
        TriggerServerEvent('vehicles_keys:selfGiveVehicleKeys', plate)
        return true
        
    elseif keyScript == 'custom' then
        -- Example:
        -- TriggerEvent('my_custom_keys:give', plate)
        SetVehicleDoorsLocked(vehicle, 1)
        return true
    end
    
    SetVehicleDoorsLocked(vehicle, 1)
    return true
end

function Keys.RemoveKeys(vehicle, plate)
    if not Config.VehicleKeys or not Config.VehicleKeys.enabled or not Config.VehicleKeys.removeKeysOnJobEnd then
        return true
    end
    
    if not vehicle or not DoesEntityExist(vehicle) then
        return false
    end
    
    plate = plate or GetVehicleNumberPlateText(vehicle)
    local modelHash = GetEntityModel(vehicle)
    local keyScript = GetKeyScript()
    
    if not keyScript then
        return true
    end
    
    if keyScript == 'qbx-vehiclekeys' then
        local success1 = pcall(function()
            exports['qbx-vehiclekeys']:RemoveNoLockVehicle(modelHash)
        end)
        
        local success2 = pcall(function()
            exports['qbx-vehiclekeys']:removeNoLockVehicles(modelHash)
        end)
        
        return success1 or success2
        
    elseif keyScript == 'qb-vehiclekeys' then
        local success = pcall(function()
            exports['qb-vehiclekeys']:removeNoLockVehicles(modelHash)
        end)
        return success
        
    elseif keyScript == 'wasabi_carlock' then
        local success = pcall(function()
            exports.wasabi_carlock:RemoveKey(plate)
        end)
        return success
        
    elseif keyScript == 'cd_garage' then
        TriggerEvent('cd_garage:RemoveKeys', plate)
        return true
        
    elseif keyScript == 'qs-vehiclekeys' then
        local success = pcall(function()
            exports['qs-vehiclekeys']:RemoveKeys(plate)
        end)
        return success
        
    elseif keyScript == 'vehicles_keys' then
        TriggerServerEvent('vehicles_keys:selfRemoveVehicleKeys', plate)
        return true
        
    elseif keyScript == 'custom' then
        -- Example:
        -- TriggerEvent('my_custom_keys:remove', plate)
        return true
    end
    
    return true
end

return Keys
