local TruckJobs = {}

local missionTrailer = nil
local missionTruck = nil
local spawnedTruck = nil 
local trailerBlip = nil
local truckBlip = nil 
local trailerMarkerActive = false
local trailerMarkerId = nil
local routeActivated = false
local currentMissionData = nil
local lastDeliveryKeyPressTime = 0
local deliveryKeyDebounceDelay = 200 
local isProcessingDelivery = false 
local wheelDamageApplied = false 
local transmissionDamageApplied = false 
local transmissionHealth = 1000.0 

function TruckJobs.CreateTrailerVisualMarker(coords)
    Citizen.CreateThread(function()
        while DoesEntityExist(missionTrailer) and not IsVehicleAttachedToTrailer(spawnedTruck) do
            Citizen.Wait(0)
            
            local trailerCoords = GetEntityCoords(missionTrailer)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
       
            local direction = trailerCoords - playerCoords
            local distance = #(direction)
            if distance > 0 then
                direction = direction / distance
            end
            
        
            local heading = math.deg(math.atan2(direction.y, direction.x))
            
         
            DrawMarker(
                0,
                trailerCoords.x, trailerCoords.y, trailerCoords.z + 3.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, heading,
                1.0, 1.0, 1.0,
                255, 122, 0, 180,
                false,
                false,
                2,
                false,
                nil, nil,
                false
            )
        end
    end)
end

function TruckJobs.CreateTrailerMarker(coords)
    trailerMarkerId = (trailerMarkerId or 0) + 1
    local currentMarkerId = trailerMarkerId
    
    trailerMarkerActive = true
    
    if missionTrailer and DoesEntityExist(missionTrailer) then
        TruckJobs.CreateTrailerVisualMarker(coords)
    end
    
    Citizen.CreateThread(function()
        local wasInVehicle = false
        local attachmentCheckStarted = false
        
        while trailerMarkerActive and trailerMarkerId == currentMarkerId and DoesEntityExist(missionTrailer) do
            Citizen.Wait(0)
            
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            local trailerPos = GetEntityCoords(missionTrailer)
            local distance = #(playerCoords - trailerPos)
            
            local inCorrectVehicle = IsPedInVehicle(playerPed, spawnedTruck, false)
            
            if inCorrectVehicle and not wasInVehicle then
                wasInVehicle = true
                
                if not attachmentCheckStarted then
                    attachmentCheckStarted = true
                    TruckJobs.CheckTrailerAttachment()
                end
            end
            
            if not IsPedInAnyVehicle(playerPed, false) and distance < 5.0 then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName(locale('get_in_truck_help') or "You need to drive the mission truck to connect this trailer")
                EndTextCommandDisplayHelp(0, false, true, 3000)
            end
        end
    end)
end

function TruckJobs.CheckTrailerAttachment()
    Citizen.CreateThread(function()
        local checkActive = true
        local isAttached = false
        
        while checkActive and not isAttached do
            Citizen.Wait(500)
            
            if not spawnedTruck or not DoesEntityExist(spawnedTruck) or 
               not missionTrailer or not DoesEntityExist(missionTrailer) then
                checkActive = false
                break
            end
            
            isAttached = IsVehicleAttachedToTrailer(spawnedTruck) 
            
            if isAttached then
                local hasTrailer, checkedTrailer = GetVehicleTrailerVehicle(spawnedTruck)
                
                if hasTrailer and checkedTrailer == missionTrailer then
                    if trailerBlip and DoesBlipExist(trailerBlip) then
                        SetBlipRoute(trailerBlip, false)
                    end
                    
                    routeActivated = false
                    trailerMarkerActive = false
                    
                    SetVehicleEngineOn(spawnedTruck, false, true, true)
                    SetVehicleUndriveable(spawnedTruck, true)
                    
                    local playerPed = PlayerPedId()
                    if IsPedInVehicle(playerPed, spawnedTruck, false) then
                        TaskLeaveVehicle(playerPed, spawnedTruck, 0)
                    end
                    
                    local currentTaskIdFromMain = exports.siberwin_trucksimulator:GetCurrentTaskIdValue()
                    TruckJobs.GetTrailer()
                end
            end
        end
    end)
end

function TruckJobs.GetTrailer()
    if not DoesEntityExist(missionTrailer) then
        return
    end
    
    if currentMissionData and currentMissionData.destination_coords then
    else
    end
    
    currentDifficulty = currentMissionData.difficulty
    selectedMission = currentMissionData
    
    if currentMissionData and currentMissionData.destination_coords then
        local destCoords = nil
        
        if type(currentMissionData.destination_coords) == 'table' and currentMissionData.destination_coords.x and currentMissionData.destination_coords.y and currentMissionData.destination_coords.z then
            if currentMissionData.destination_coords.w then
                destCoords = vector4(
                    currentMissionData.destination_coords.x, 
                    currentMissionData.destination_coords.y, 
                    currentMissionData.destination_coords.z, 
                    currentMissionData.destination_coords.w
                )
            else
                destCoords = vector3(
                    currentMissionData.destination_coords.x, 
                    currentMissionData.destination_coords.y, 
                    currentMissionData.destination_coords.z
                )
            end
        else
            destCoords = ParseCoordsFlexible(currentMissionData.destination_coords)
        end
        
        if destCoords then
            CreateMissionDestination(destCoords)
        else
            print("[ERROR] Destination coordinates could not be converted!")
        end
    else
    end
end

local missionFailedDueToDamage = false

function TruckJobs.CheckTrailerHealth()
    Citizen.CreateThread(function()
        while DoesEntityExist(missionTrailer) do
            Citizen.Wait(1000) 

            local trailerHealth = GetVehicleBodyHealth(missionTrailer)
            local maxHealth = 1000.0
            local healthPercentage = (trailerHealth / maxHealth) * 100.0
            
            if healthPercentage <= 10.0 then
                missionFailedDueToDamage = true
                
                if truckBlip and DoesBlipExist(truckBlip) then RemoveBlip(truckBlip); truckBlip = nil end
                if trailerBlip and DoesBlipExist(trailerBlip) then RemoveBlip(trailerBlip); trailerBlip = nil end
                if destinationBlip and DoesBlipExist(destinationBlip) then RemoveBlip(destinationBlip); destinationBlip = nil end

                TriggerEvent('siberwin_trucksimulator:setJobStartedState', false)
                TriggerEvent('siberwin_trucksimulator:setReturnWaypoint')

                break
            end
        end
    end)
end

function TruckJobs.CreateTruckVisualMarker(coords)
    Citizen.CreateThread(function()
        while missionTruck and DoesEntityExist(missionTruck) and not IsPedInVehicle(PlayerPedId(), missionTruck, false) do
            Citizen.Wait(0)
            
            local missionTruckCoords = GetEntityCoords(missionTruck)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
      
            local direction = missionTruckCoords - playerCoords
            local distance = #(direction)
            if distance > 0 then
                direction = direction / distance
            end
            
      
            local heading = math.deg(math.atan2(direction.y, direction.x))
            
            DrawMarker(
                0, 
                missionTruckCoords.x, missionTruckCoords.y, missionTruckCoords.z + 3.5,
                0.0, 0.0, 0.0,
                0.0, 0.0, heading,
                1.5, 1.5, 1.5,
                0, 122, 255, 200,
                true,
                false,
                2,
                false,
                nil, nil,
                false
            )
        end
        
        if DoesEntityExist(missionTruck) and IsPedInVehicle(PlayerPedId(), missionTruck, false) and 
           missionTrailer and DoesEntityExist(missionTrailer) and not IsVehicleAttachedToTrailer(missionTruck) then
            if trailerBlip and DoesBlipExist(trailerBlip) then
                SetBlipRoute(trailerBlip, true)
                SetBlipRouteColour(trailerBlip, 5)
                
                if not routeActivated then
                    routeActivated = true
                end
            end
        end
    end)
end

function TruckJobs.StartMission(level, mission)
    currentMissionData = mission
    
    currentDifficulty = mission.difficulty
    selectedMission = mission
    
    wheelDamageApplied = false
    transmissionDamageApplied = false

    transmissionHealth = 1000.0
    
    if exports.siberwin_trucksimulator and exports.siberwin_trucksimulator.SetupTaskListForMission then
        exports.siberwin_trucksimulator:SetupTaskListForMission("trucker", mission.name)
    else
    end

    local availableSpawnPoints = {}
    for _, spawnPoint in ipairs(Config.TruckSpawnPoints) do
        if Wrapper.IsSpawnPointClear(spawnPoint, 5.0) then
            table.insert(availableSpawnPoints, spawnPoint)
        end
    end
    
    if #availableSpawnPoints == 0 then
        lib.notify({
            title = "Error",
            description = "No suitable spawn point found. Please try again later.",
            type = 'error'
        })
        return
    end
    
    local truckCoords = nil
    local truckHeading = 0.0
    
    if mission.partyMission then
        local playerServerId = GetPlayerServerId(PlayerId())
        
        local spawnIndex = (playerServerId % #availableSpawnPoints) + 1
        
        truckCoords = availableSpawnPoints[spawnIndex]
        truckHeading = (truckCoords.w ~= nil) and truckCoords.w or 0.0
    else
        local randomIndex = math.random(1, #availableSpawnPoints)
        truckCoords = availableSpawnPoints[randomIndex]
        truckHeading = (truckCoords.w ~= nil) and truckCoords.w or 0.0
    end
    
    Citizen.SetTimeout(2000, function()
        Wrapper.SpawnVehicle(mission.truckModel, truckCoords, truckHeading, function(vehicle)
            if not vehicle then
                 return
            end
            
            missionTruck = vehicle
            
            SetVehicleUndriveable(vehicle, true)
            SetVehicleEngineOn(vehicle, false, true, true)
            
            local attempts = 0
            local maxAttempts = 20
            while not NetworkGetEntityIsNetworked(vehicle) and attempts < maxAttempts do
                NetworkRegisterEntityAsNetworked(vehicle)
                attempts = attempts + 1
                Citizen.Wait(50)
            end
            
            local plate = mission.plate or GetVehicleNumberPlateText(vehicle)
            
            if mission.plate then
                SetVehicleNumberPlateText(vehicle, plate)
                Citizen.Wait(100)
                local currentPlate = GetVehicleNumberPlateText(vehicle)
                
                if currentPlate ~= plate then
                    SetVehicleNumberPlateText(vehicle, plate)
                end
            end
            
            if Framework == 'qbcore' then
                Keys.GiveKeys(vehicle, plate)
            elseif Framework == 'esx' then
               
            end
            
            SetVehicleDoorsLocked(vehicle, 1)


            if Config.Inventory and Config.Inventory.enabled and mission.cargoType ~= nil then
                local modelHash = GetEntityModel(vehicle)
                local modelName = GetDisplayNameFromVehicleModel(modelHash)
                TriggerServerEvent('trucker:giveJobPaper', {
                    jobName = mission.name,
                    cargoType = mission.cargoType,
                    truckModel = modelName,
                    plate = plate
                })
            end
            
            SetVehicleDamageModifier(vehicle, 0.0)
            
            if mission.truckHealth then
                
                local engineHealth = 1000.0
                local bodyHealth = 1000.0
                local fuelLevel = Config.FuelSystem.defaultFuel or 100.0
                local wheelsHealth = 1000.0 
                
                if mission.truckHealth.engine ~= nil then
                    if type(mission.truckHealth.engine) == "string" then
                        local cleanValue = string.match(mission.truckHealth.engine, "^%s*(%d+%.?%d*)%s*$")
                        engineHealth = cleanValue and tonumber(cleanValue) or 1000.0
                    else
                        engineHealth = tonumber(mission.truckHealth.engine) or 1000.0
                    end
                end
                
                if mission.truckHealth.body ~= nil then
                    if type(mission.truckHealth.body) == "string" then
                        local cleanValue = string.match(mission.truckHealth.body, "^%s*(%d+%.?%d*)%s*$")
                        bodyHealth = cleanValue and tonumber(cleanValue) or 1000.0
                    else
                        bodyHealth = tonumber(mission.truckHealth.body) or 1000.0
                    end
                end
                
                if mission.truckHealth.fuel ~= nil then
                    if type(mission.truckHealth.fuel) == "string" then
                        local cleanValue = string.match(mission.truckHealth.fuel, "^%s*(%d+%.?%d*)%s*$")
                        fuelLevel = cleanValue and tonumber(cleanValue) or (Config.FuelSystem.defaultFuel or 100.0)
                    else
                        fuelLevel = tonumber(mission.truckHealth.fuel) or (Config.FuelSystem.defaultFuel or 100.0)
                    end
                end
                
              
                if mission.truckHealth.wheels ~= nil then
                    if type(mission.truckHealth.wheels) == "string" then
                        local cleanValue = string.match(mission.truckHealth.wheels, "^%s*(%d+%.?%d*)%s*$")
                        wheelsHealth = cleanValue and tonumber(cleanValue) or 1000.0
                    else
                        wheelsHealth = tonumber(mission.truckHealth.wheels) or 1000.0
                    end
                end
                
                if fuelLevel < 0 or fuelLevel > 100 then
                    fuelLevel = 100.0
                end
                
                if type(engineHealth) ~= "number" then
                    engineHealth = 1000.0
                end
                
                if type(bodyHealth) ~= "number" then
                    bodyHealth = 1000.0
                end
                
                if type(fuelLevel) ~= "number" then
                    fuelLevel = 100.0
                end
                
                if type(wheelsHealth) ~= "number" then
                    wheelsHealth = 1000.0
                end
                
                engineHealth = math.floor(engineHealth * 10) / 10
                bodyHealth = math.floor(bodyHealth * 10) / 10
                fuelLevel = math.floor(fuelLevel * 10) / 10
                wheelsHealth = math.floor(wheelsHealth * 10) / 10 
                
                fuelLevel = math.min(fuelLevel, 100.0)
                
                SetVehicleEngineHealth(vehicle, engineHealth)
                SetVehicleBodyHealth(vehicle, bodyHealth)
                
                SetVehicleFuelSafely(vehicle, fuelLevel)
                
             
                local numWheels = GetVehicleNumberOfWheels(vehicle)
                for i = 0, numWheels - 1 do
                    SetVehicleWheelHealth(vehicle, i, wheelsHealth)
                end

             
                local currentBodyHealthForDamageCheck = GetVehicleBodyHealth(vehicle)

                if currentBodyHealthForDamageCheck <= 250 then
                    SetVehicleDoorBroken(vehicle, 0, true) 
                    SetVehicleDoorBroken(vehicle, 1, true) 
                    SetVehicleDoorBroken(vehicle, 4, true) 
                    local numWheels = GetVehicleNumberOfWheels(vehicle)
                    for i = 0, numWheels - 1 do
                        SetVehicleTyreBurst(vehicle, i, true, 1000.0)
                    end
                elseif currentBodyHealthForDamageCheck <= 500 then
                    SetVehicleDoorBroken(vehicle, 0, true) 
                    SetVehicleDoorBroken(vehicle, 1, true) 
                    SetVehicleDoorBroken(vehicle, 4, true) 
                elseif currentBodyHealthForDamageCheck <= 750 then
                    SetVehicleDoorBroken(vehicle, 0, true) 
                    SetVehicleDoorBroken(vehicle, 1, true) 
                end

            else
                SetVehicleEngineHealth(vehicle, 1000.0)
                SetVehicleBodyHealth(vehicle, 1000.0)
                SetVehicleFuelSafely(vehicle, Config.FuelSystem.defaultFuel or 100.0)
                
              
                local numWheels = GetVehicleNumberOfWheels(vehicle)
                for i = 0, numWheels - 1 do
                    SetVehicleWheelHealth(vehicle, i, 1000.0)
                end
            end
            
            SetVehicleDirtLevel(vehicle, 0.0)
            
            Citizen.Wait(100)
            SetVehicleJetEngineOn(vehicle, false)
            
            Citizen.Wait(100)
            SetVehicleDamageModifier(vehicle, 1.0)
            SetVehicleUndriveable(vehicle, false)
            
            if mission.truckColors then
                if mission.truckColors.primary then
                    SetVehicleCustomPrimaryColour(vehicle, mission.truckColors.primary.r, mission.truckColors.primary.g, mission.truckColors.primary.b)
                end
                if mission.truckColors.secondary then
                    SetVehicleCustomSecondaryColour(vehicle, mission.truckColors.secondary.r, mission.truckColors.secondary.g, mission.truckColors.secondary.b)
                end
            end
            
            local uniqueMissionId = "plate:" .. plate
            TriggerEvent('trucker:diagnostics:trackVehicle', vehicle, uniqueMissionId, mission.truckModel)
            
            if truckBlip and DoesEntityExist(truckBlip) then RemoveBlip(truckBlip) end
            truckBlip = AddBlipForEntity(missionTruck)
            SetBlipSprite(truckBlip, 477)
            SetBlipColour(truckBlip, 3)
            SetBlipScale(truckBlip, 0.9)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(locale('mission_truck') or "Mission Truck")
            EndTextCommandSetBlipName(truckBlip)
            
            TruckJobs.CreateTruckVisualMarker(truckCoords)
            spawnedTruck = missionTruck

            -- Start wheel damage tracking for mission
            TruckJobs.ApplyWheelDamage()
            -- Start transmission damage tracking for mission
            TruckJobs.ApplyTransmissionDamage()

            if mission.trailerModel and mission.trailerModel ~= '' then
    
                local trailerSpawnCoords = nil
                local trailerSpawnHeading = 0.0
                
                if mission.trailerSpawnCoords then
                    local desiredSpawn = mission.trailerSpawnCoords
                    if Wrapper.IsSpawnPointClear(desiredSpawn, 5.0) then
                        trailerSpawnCoords = desiredSpawn
                        trailerSpawnHeading = (desiredSpawn.w ~= nil) and desiredSpawn.w or 0.0
                    else
                        -- Belirtilen spawn noktası doluysa global spawn noktalarına düş
                        local availableTrailerSpawnPoints = {}
                        for _, spawnPoint in ipairs(Config.TrailerSpawnPoints) do
                            if Wrapper.IsSpawnPointClear(spawnPoint, 5.0) then
                                table.insert(availableTrailerSpawnPoints, spawnPoint)
                            end
                        end
                        
                        if #availableTrailerSpawnPoints == 0 then
                            if DoesEntityExist(missionTruck) then 
                                local plate = GetVehicleNumberPlateText(missionTruck)
                                TriggerEvent('trucker:diagnostics:untrackVehicle', "plate:" .. plate)
                                DeleteEntity(missionTruck) 
                            end
                            if truckBlip and DoesBlipExist(truckBlip) then RemoveBlip(truckBlip); truckBlip = nil end
                            spawnedTruck = nil; missionTruck = nil;
                            
                            lib.notify({
                                title = "Error",
                                description = "No suitable spawn point found for the trailer.",
                                type = 'error'
                            })
                            return
                        end
                        
                        local randomTrailerIndex = math.random(1, #availableTrailerSpawnPoints)
                        trailerSpawnCoords = availableTrailerSpawnPoints[randomTrailerIndex]
                        trailerSpawnHeading = (trailerSpawnCoords.w ~= nil) and trailerSpawnCoords.w or 0.0
                        
                        if mission.partyMission then
                            local playerServerId = GetPlayerServerId(PlayerId())
                            local trailerSpawnIndex = ((playerServerId + 1) % #availableTrailerSpawnPoints) + 1
                            trailerSpawnCoords = availableTrailerSpawnPoints[trailerSpawnIndex]
                            trailerSpawnHeading = (trailerSpawnCoords.w ~= nil) and trailerSpawnCoords.w or 0.0
                        end
                    end
                else
                    -- Diğer görev türleri için eski sistem: uygun nokta bul
                    local availableTrailerSpawnPoints = {}
                    for _, spawnPoint in ipairs(Config.TrailerSpawnPoints) do
                        if Wrapper.IsSpawnPointClear(spawnPoint, 5.0) then
                            table.insert(availableTrailerSpawnPoints, spawnPoint)
                        end
                    end
                
                    if #availableTrailerSpawnPoints == 0 then
                        if DoesEntityExist(missionTruck) then 
                            local plate = GetVehicleNumberPlateText(missionTruck)
                            TriggerEvent('trucker:diagnostics:untrackVehicle', "plate:" .. plate)
                            DeleteEntity(missionTruck) 
                        end
                        if truckBlip and DoesBlipExist(truckBlip) then RemoveBlip(truckBlip); truckBlip = nil end
                        spawnedTruck = nil; missionTruck = nil;
                        
                        lib.notify({
                            title = "Error",
                            description = "No suitable spawn point found for the trailer.",
                            type = 'error'
                        })
                        return
                    end
                
                    local randomTrailerIndex = math.random(1, #availableTrailerSpawnPoints)
                    trailerSpawnCoords = availableTrailerSpawnPoints[randomTrailerIndex]
                    trailerSpawnHeading = (trailerSpawnCoords.w ~= nil) and trailerSpawnCoords.w or 0.0
                
                    if mission.partyMission then
                        local playerServerId = GetPlayerServerId(PlayerId())
                        local trailerSpawnIndex = ((playerServerId + 1) % #availableTrailerSpawnPoints) + 1
                        trailerSpawnCoords = availableTrailerSpawnPoints[trailerSpawnIndex]
                        trailerSpawnHeading = (trailerSpawnCoords.w ~= nil) and trailerSpawnCoords.w or 0.0
                    end
                end
                
                    Wrapper.SpawnVehicle(mission.trailerModel, trailerSpawnCoords, trailerSpawnHeading, function(trailer)
                        if trailer then
                            missionTrailer = trailer

                            -- İlk spawn’da dorsenin hareketini kilitleme İPTAL (Havada kalma sorunu)
                            -- FreezeEntityPosition(missionTrailer, true)
                            -- SetVehicleHandbrake(missionTrailer, true)
                            
                            if trailerBlip and DoesBlipExist(trailerBlip) then RemoveBlip(trailerBlip) end
                            trailerBlip = AddBlipForEntity(missionTrailer)
                            SetBlipSprite(trailerBlip, 479)
                            SetBlipColour(trailerBlip, 5)
                            SetBlipScale(trailerBlip, 0.9)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString(locale('mission_trailer') or "Mission Trailer")
                            EndTextCommandSetBlipName(trailerBlip)

                            TruckJobs.CheckTrailerHealth()

                            Citizen.SetTimeout(500, function()
                                if missionTrailer and DoesEntityExist(missionTrailer) then
                                    TruckJobs.CreateTrailerMarker(trailerSpawnCoords)
                                end
                            end)
                        else
                            if DoesEntityExist(missionTruck) then 
                                local plate = GetVehicleNumberPlateText(missionTruck)
                                TriggerEvent('trucker:diagnostics:untrackVehicle', "plate:" .. plate)
                                DeleteEntity(missionTruck) 
                            end
                            if truckBlip and DoesBlipExist(truckBlip) then RemoveBlip(truckBlip); truckBlip = nil end
                            spawnedTruck = nil; missionTruck = nil;
                            FinishJob(mission.difficulty, mission)
                        end
                    end)

            else
                if mission.destination_coords then
                    local destCoords = nil
                    
                    if type(mission.destination_coords) == 'table' and mission.destination_coords.x and mission.destination_coords.y and mission.destination_coords.z then
                        if mission.destination_coords.w then
                            destCoords = vector4(
                                mission.destination_coords.x, 
                                mission.destination_coords.y, 
                                mission.destination_coords.z, 
                                mission.destination_coords.w
                            )
                        else
                            destCoords = vector3(
                                mission.destination_coords.x, 
                                mission.destination_coords.y, 
                                mission.destination_coords.z
                            )
                        end
                    else
                        destCoords = ParseCoordsFlexible(mission.destination_coords)
                    end
                    
                    if destCoords then
                        CreateMissionDestination(destCoords)
                    else
                        print("[ERROR] Destination coordinates could not be converted!")
                    end
                end
            end
        end)
    end)
end

function TruckJobs.CheckAlignmentAndDelivery(targetCoords, _)
    local markerColor = {r = 229, g = 57, b = 53, a = 150}
    local currentTaskStatus = nil
    local currentTaskDescription = nil
    local deliveredResult = false

    local hasTrailer = false
    local trailerEntity = nil
    local trailerCoords = nil
    local trailerDistance = 999.0

    if spawnedTruck and DoesEntityExist(spawnedTruck) then
        local isAttached = IsVehicleAttachedToTrailer(spawnedTruck)
        if isAttached then
            local hasTrailer2, trailer = GetVehicleTrailerVehicle(spawnedTruck)
            if hasTrailer2 and trailer and DoesEntityExist(trailer) then
                hasTrailer = true
                trailerEntity = trailer
                trailerCoords = GetEntityCoords(trailer)
            end
        elseif missionTrailer and DoesEntityExist(missionTrailer) then
            hasTrailer = true
            trailerEntity = missionTrailer
            trailerCoords = GetEntityCoords(missionTrailer)
        end
    end

    if hasTrailer and trailerCoords then
        local trailerPos = vector2(trailerCoords.x, trailerCoords.y)
        local markerPos = vector2(targetCoords.x, targetCoords.y)
        trailerDistance = #(trailerPos - markerPos)

        local deliveryRadius = 10.0
        if trailerDistance <= deliveryRadius then
            markerColor = {r = 0, g = 255, b = 0, a = 150}
            currentTaskStatus = locale('task_press_to_deliver') or "Press to deliver"
            currentTaskDescription = locale('desc_press_to_deliver') or "Press [E] to complete delivery"

            if IsControlJustPressed(0, 38) then
                local currentTime = GetGameTimer()
                if currentTime - lastDeliveryKeyPressTime < deliveryKeyDebounceDelay then
                    return deliveredResult, markerColor, currentTaskStatus, currentTaskDescription
                end

                if isProcessingDelivery then
                    return deliveredResult, markerColor, currentTaskStatus, currentTaskDescription
                end

                lastDeliveryKeyPressTime = currentTime
                isProcessingDelivery = true
                DisableControlAction(0, 38, true)
                DoScreenFadeOut(500)

                SendNUIMessage({ type = 'playSound', soundName = 'trailer2', volume = 0.7 })

                Citizen.SetTimeout(4000, function()
                    CompleteCurrentTask()

                    if destinationBlip and DoesBlipExist(destinationBlip) then RemoveBlip(destinationBlip); destinationBlip = nil end
                    TriggerEvent('trucker:clearDeliveryBlip')

                    if trailerEntity and DoesEntityExist(trailerEntity) and trailerEntity ~= spawnedTruck then
                        if trailerBlip and DoesBlipExist(trailerBlip) then RemoveBlip(trailerBlip); trailerBlip = nil end
                        DeleteEntity(trailerEntity)
                        missionTrailer = nil
                    end

                    if trailerBlip and DoesBlipExist(trailerBlip) then RemoveBlip(trailerBlip); trailerBlip = nil end
                    if truckBlip and DoesBlipExist(truckBlip) then RemoveBlip(truckBlip); truckBlip = nil end

                    delivered = true
                    returnMarkersCurrentlyActive = true  -- Marker flag'ini hemen aktif et (timing sorunu önleme)
                    deliveredResult = true
                    missionMarkerCoords = nil
                    SetReturnWaypoint()

                    DoScreenFadeIn(1000)
                    Citizen.SetTimeout(1000, function()
                        DisableControlAction(0, 38, false)
                        isProcessingDelivery = false
                    end)
                end)
            end
        else
            markerColor = {r = 229, g = 57, b = 53, a = 150}
            -- Dışarıdayken statü metnini mevcut çeviri anahtarından kullan
            currentTaskStatus = locale('delivery_point') or "Delivery Point"
            currentTaskDescription = currentTaskDescription or nil
        end
    else
        markerColor = {r = 229, g = 57, b = 53, a = 150}
        currentTaskStatus = locale('task_trailer_missing') or "Trailer missing"
        currentTaskDescription = locale('desc_trailer_missing') or "Make sure your trailer is attached to the truck."
    end

    return deliveredResult, markerColor, currentTaskStatus, currentTaskDescription
end

function TruckJobs.GetMissionTruck()
    return missionTruck
end

function TruckJobs.GetMissionTrailer()
    return missionTrailer
end

function TruckJobs.DidMissionFailDueToDamage()
    return missionFailedDueToDamage
end

function TruckJobs.ResetMissionFailedDueToDamage()
    missionFailedDueToDamage = false
end


function TruckJobs.MarkMissionFailedDueToCheck()
    missionFailedDueToDamage = true
end


function TruckJobs.ApplyWheelDamage()
    if wheelDamageApplied or not spawnedTruck or not DoesEntityExist(spawnedTruck) then
        return
    end
    
    Citizen.CreateThread(function()
        Citizen.Wait(5000) 
        
        local lastSpeed = 0.0
        local damageApplied = 0.0
        
        while spawnedTruck and DoesEntityExist(spawnedTruck) and not wheelDamageApplied do
            Citizen.Wait(2000) 
            
            local currentSpeed = GetEntitySpeed(spawnedTruck)
            local isOnGround = IsEntityInAir(spawnedTruck)
            
          
            if lastSpeed > 15.0 and currentSpeed < lastSpeed - 8.0 then
                damageApplied = damageApplied + 1.5
            end
            
          
            if currentSpeed > 25.0 then
                damageApplied = damageApplied + 0.5
            end
            if currentSpeed > 35.0 then
                damageApplied = damageApplied + 1.0
            end
            
        
            if not isOnGround and currentSpeed > 2.0 then
                damageApplied = damageApplied + 1.0
            end
            
         
            if lastSpeed <= 15.0 and currentSpeed >= lastSpeed - 8.0 and currentSpeed <= 25.0 and isOnGround and currentSpeed > 0.1 then
                damageApplied = math.max(0.0, damageApplied - 0.8)
            end
            
            if currentSpeed <= 0.1 then
                damageApplied = 0.0
            end
            
            if damageApplied >= 8.0 then
                local numWheels = GetVehicleNumberOfWheels(spawnedTruck)
                
                for wheelIndex = 0, numWheels - 1 do
                    local currentWheelHealth = GetVehicleWheelHealth(spawnedTruck, wheelIndex)
                    
                    if currentWheelHealth > 0 then
                        local damageAmount = math.random(3, 8)
                        local newWheelHealth = math.max(0.0, currentWheelHealth - damageAmount)
                        
                        SetVehicleWheelHealth(spawnedTruck, wheelIndex, newWheelHealth)
                        
                        if newWheelHealth <= 0.0 then
                            SetVehicleTyreBurst(spawnedTruck, wheelIndex, true, 1000.0)
                        end
                    elseif currentWheelHealth <= 0.0 then
                        SetVehicleTyreBurst(spawnedTruck, wheelIndex, true, 1000.0)
                    end
                end
                
                damageApplied = 0.0
                
                local plate = GetVehicleNumberPlateText(spawnedTruck)
                local uniqueMissionId = "plate:" .. plate
                
                local averageWheelHealth = TruckJobs.GetAverageWheelHealth()
                
                SendNUIMessage({
                    type = 'updateTruckHealth',
                    purchaseId = uniqueMissionId,
                    engine = GetVehicleEngineHealth(spawnedTruck),
                    body = GetVehicleBodyHealth(spawnedTruck),
                    fuel = GetVehicleFuelLevel(spawnedTruck),
                    wheels = averageWheelHealth,
                    transmission = transmissionHealth
                })
            end
            
            lastSpeed = currentSpeed
        end
    end)
end

 

function TruckJobs.ApplyTransmissionDamage()
    if transmissionDamageApplied then
        return
    end

    Citizen.CreateThread(function()
        Citizen.Wait(8000)

        local lastRPM = 0.0
        local damageApplied = 0.0
        local gearChanges = 0
        local lastGear = 0

        while not transmissionDamageApplied do
            Citizen.Wait(3000)

            local vehicle = spawnedTruck
            if not vehicle or not DoesEntityExist(vehicle) then
                break
            end

            local engineRunning = GetIsVehicleEngineRunning(vehicle)
            local currentSpeed = GetEntitySpeed(vehicle) or 0.0

            local currentRPM = 0.0
            local currentGear = lastGear
            if engineRunning then
                if DoesEntityExist(vehicle) then
                    currentRPM = GetVehicleCurrentRpm(vehicle) or 0.0
                    currentGear = GetVehicleCurrentGear(vehicle) or lastGear
                else
                    break
                end
            end

            if currentGear ~= lastGear then
                gearChanges = gearChanges + 1
            end
            local previousGear = lastGear
            lastGear = currentGear

            if currentGear < previousGear and currentSpeed > 15.0 then
                damageApplied = damageApplied + 2.0
            end

            if currentRPM > 0.8 then
                damageApplied = damageApplied + 1.0
            elseif currentRPM > 0.6 then
                damageApplied = damageApplied + 0.5
            end

            if currentRPM > 0.7 and lastRPM < 0.4 then
                damageApplied = damageApplied + 1.5
            end

            if gearChanges > 3 then
                damageApplied = damageApplied + 1.0
                gearChanges = 0
            end

            if currentRPM <= 0.5 and currentSpeed > 0.1 then
                damageApplied = math.max(0.0, damageApplied - 0.5)
            end

            if currentSpeed <= 0.1 then
                damageApplied = 0.0
                gearChanges = 0
            end

            if damageApplied >= 10.0 then
                local newTransmissionHealth = math.max(0.0, transmissionHealth - math.random(5, 15))
                transmissionHealth = newTransmissionHealth

                local plate = GetVehicleNumberPlateText(vehicle) or ""
                local uniqueMissionId = "plate:" .. plate

                SendNUIMessage({
                    type = 'updateTruckHealth',
                    purchaseId = uniqueMissionId,
                    engine = GetVehicleEngineHealth(vehicle),
                    body = GetVehicleBodyHealth(vehicle),
                    fuel = GetVehicleFuelLevel(vehicle),
                    wheels = TruckJobs.GetAverageWheelHealth(),
                    transmission = transmissionHealth
                })

                TriggerEvent('trucker:diagnostics:updateTransmissionHealth', transmissionHealth)

                if transmissionHealth < 300.0 then
                    SendNUIMessage({
                        type = 'showNotification',
                        message = 'Warning: Transmission damage detected. Get it repaired soon!',
                        notificationType = 'error'
                    })
                elseif transmissionHealth < 600.0 then
                    SendNUIMessage({
                        type = 'showNotification',
                        message = 'Transmission stress detected. Drive more carefully to avoid damage.',
                        notificationType = 'warning'
                    })
                end

                damageApplied = 0.0
            end

            lastRPM = currentRPM
        end
    end)
end

function TruckJobs.GetAverageWheelHealth()
    if not spawnedTruck or not DoesEntityExist(spawnedTruck) then
        return 1000.0
    end
    
    local numWheels = GetVehicleNumberOfWheels(spawnedTruck)
    local totalWheelHealth = 0
    local wheelCount = 0
    
    for i = 0, numWheels - 1 do
        local tireHealth = GetVehicleWheelHealth(spawnedTruck, i)
        totalWheelHealth = totalWheelHealth + tireHealth
        wheelCount = wheelCount + 1
    end
    
    if wheelCount > 0 then
        return totalWheelHealth / wheelCount
    else
        return 1000.0
    end
end

return TruckJobs