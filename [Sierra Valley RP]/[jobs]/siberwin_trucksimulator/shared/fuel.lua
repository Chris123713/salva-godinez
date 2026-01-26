
function IsFuelSystemAvailable()
   
    if not Config.FuelSystem or not Config.FuelSystem.enabled then
        return false
    end
    
    local resourceName = Config.FuelSystem.script
    
    if not resourceName or resourceName == "" then
        return false
    end
    
    local resourceState = GetResourceState(resourceName)
    
    if resourceState ~= 'started' then
        return false
    end
    
    if not exports[resourceName] then
        return false
    end
    
    if resourceName == 'LegacyFuel' then
        if exports[resourceName].SetFuel then
            return "LegacyFuel"
        elseif exports[resourceName].setFuel then
            return "LegacyFuel"
        else
            return false
        end
    elseif resourceName == 'ox_fuel' then
        return "ox_fuel"
    elseif resourceName == 'cd_fuel' or resourceName == 'cdn_fuel' or resourceName == 'cdn-fuel' then
        if not exports[resourceName].SetFuel then
            return false
        end
        return resourceName
    elseif resourceName == 'ps_fuel' then
        if not exports[resourceName].SetFuel then
            return false
        end
        return "ps_fuel"
    elseif resourceName == 'my_fuel' then -- Your own fuel system
        if not exports[resourceName].setFuel then
            return false
        end
        return "my_fuel"
    else
        local success = pcall(function()
            return exports[resourceName].SetFuel ~= nil
        end)
        
        if success then
            return resourceName
        else
            return false
        end
    end
end

function SetVehicleFuelSafely(vehicle, fuelLevel)
    if not DoesEntityExist(vehicle) then
        return
    end
    
    local clampedFuel = math.max(0.0, math.min(100.0, fuelLevel))
    
    local fuelSystem = IsFuelSystemAvailable()
    
    if fuelSystem then
        if fuelSystem == "ox_fuel" then
            Entity(vehicle).state:set("fuel", clampedFuel, true)
        elseif fuelSystem == "LegacyFuel" then
            local success, result
            if exports[fuelSystem].SetFuel then
                success, result = pcall(function()
                    return exports[fuelSystem]:SetFuel(vehicle, clampedFuel)
                end)
            else
                success, result = pcall(function()
                    return exports[fuelSystem]:setFuel(vehicle, clampedFuel)
                end)
            end
        elseif fuelSystem == "cd_fuel" or fuelSystem == "cdn_fuel" or fuelSystem == "cdn-fuel" or fuelSystem == "ps_fuel" then
            local success, result = pcall(function()
                return exports[fuelSystem]:SetFuel(vehicle, clampedFuel)
            end)
        elseif fuelSystem == "my_fuel" then -- Your own fuel system
            local success, result = pcall(function()
                return exports[fuelSystem]:setFuel(vehicle, clampedFuel)
            end)
        else
            local success, result = pcall(function()
                return exports[fuelSystem]:SetFuel(vehicle, clampedFuel)
            end)
        end
    end
    
    SetVehicleFuelLevel(vehicle, clampedFuel)
end

function GetVehicleFuelSafely(vehicle)
    if not DoesEntityExist(vehicle) then
        return 0.0
    end
    
    local nativeFuel = GetVehicleFuelLevel(vehicle)
    
    local fuelSystem = IsFuelSystemAvailable()
    
    if not fuelSystem then
        return nativeFuel
    end
    
    local externalFuel = nativeFuel
    
    if fuelSystem == "ox_fuel" then
        local stateFuel = Entity(vehicle).state.fuel
        if stateFuel then
            externalFuel = stateFuel
        end
    elseif fuelSystem == "LegacyFuel" then
        local success, result
        if exports[fuelSystem].GetFuel then
            success, result = pcall(function()
                return exports[fuelSystem]:GetFuel(vehicle)
            end)
        else
            success, result = pcall(function()
                return exports[fuelSystem]:getFuel(vehicle)
            end)
        end
        
        if success and type(result) == "number" then
            externalFuel = result
        end
    elseif fuelSystem == "cd_fuel" or fuelSystem == "cdn_fuel" or fuelSystem == "cdn-fuel" or fuelSystem == "ps_fuel" then
        local success, result = pcall(function()
            return exports[fuelSystem]:GetFuel(vehicle)
        end)
        if success and type(result) == "number" then
            externalFuel = result
        end
    elseif fuelSystem == "my_fuel" then -- Your own fuel system
        local success, result = pcall(function()
            return exports[fuelSystem]:getFuel(vehicle)
        end)
        if success and type(result) == "number" then
            externalFuel = result
        end
    else
        local success, result = pcall(function()
            return exports[fuelSystem]:GetFuel(vehicle)
        end)
        if success and type(result) == "number" then
            externalFuel = result
        end
    end
    
    return externalFuel
end 

--You can integrate your own fuel system components. 
--Also, don't forget to enter the name of the fuel system script in config.lua.