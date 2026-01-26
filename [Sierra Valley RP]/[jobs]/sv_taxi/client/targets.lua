-- ox_target Integration for Taxi Stands
local QBCore = exports['qbx_core']:GetCoreObject()

-- Create blips for taxi stands
CreateThread(function()
    for i, stand in ipairs(Config.TaxiStands) do
        if stand.blip then
            local blip = AddBlipForCoord(stand.coords.x, stand.coords.y, stand.coords.z)
            SetBlipSprite(blip, Config.Blips.stand.sprite)
            SetBlipColour(blip, Config.Blips.stand.color)
            SetBlipScale(blip, Config.Blips.stand.scale)
            SetBlipDisplay(blip, Config.Blips.stand.display)
            SetBlipAsShortRange(blip, Config.Blips.stand.shortRange)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(stand.name)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Create ox_target zones for taxi stands
CreateThread(function()
    Wait(1000) -- Wait for other resources to load

    for i, stand in ipairs(Config.TaxiStands) do
        if Config.EnableDebug then
            print('^3[SV_TAXI]^7 Creating ox_target zone at: ' .. stand.name .. ' - ' .. tostring(stand.coords))
        end

        exports.ox_target:addBoxZone({
            coords = stand.coords,
            size = vec3(3.0, 3.0, 3.0), -- Increased size for easier targeting
            rotation = stand.heading,
            debug = Config.EnableDebug,
            options = {
                {
                    name = 'taxi_duty_toggle_' .. i,
                    icon = 'fa-solid fa-id-card',
                    label = 'Clock In/Out',
                    groups = Config.JobName,
                    onSelect = function()
                        TriggerServerEvent('QBCore:ToggleDuty')
                        lib.notify({
                            type = 'success',
                            description = 'Duty status toggled'
                        })
                    end
                },
                {
                    name = 'taxi_open_menu_' .. i,
                    icon = 'fa-solid fa-taxi',
                    label = 'Open Taxi Menu',
                    groups = Config.JobName,
                    canInteract = function(entity, distance, coords, name, bone)
                        local Player = QBCore.Functions.GetPlayerData()
                        return Player.job and Player.job.name == Config.JobName and Player.job.onduty
                    end,
                    onSelect = function()
                        exports['sv_taxi']:OpenTaxiUI()
                    end
                },
                {
                    name = 'taxi_spawn_vehicle_' .. i,
                    icon = 'fa-solid fa-car',
                    label = 'Quick Spawn Vehicle',
                    groups = Config.JobName,
                    canInteract = function(entity, distance, coords, name, bone)
                        local Player = QBCore.Functions.GetPlayerData()
                        return Player.job and Player.job.name == Config.JobName and Player.job.onduty
                    end,
                    onSelect = function()
                        lib.registerContext({
                            id = 'taxi_quick_spawn',
                            title = 'Quick Spawn Vehicle',
                            options = GetQuickSpawnOptions(stand.vehicleSpawn)
                        })
                        lib.showContext('taxi_quick_spawn')
                    end
                },
                {
                    name = 'taxi_start_npc_job_' .. i,
                    icon = 'fa-solid fa-user',
                    label = 'Request NPC Passenger',
                    groups = Config.JobName,
                    canInteract = function()
                        local Player = QBCore.Functions.GetPlayerData()
                        if not Player.job or Player.job.name ~= Config.JobName or not Player.job.onduty then
                            return false
                        end
                        local ped = PlayerPedId()
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        return vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped
                    end,
                    onSelect = function()
                        exports['sv_taxi']:StartNPCJob()
                    end
                },
                {
                    name = 'taxi_cancel_job_' .. i,
                    icon = 'fa-solid fa-times',
                    label = 'Cancel Current Job',
                    groups = Config.JobName,
                    canInteract = function(entity, distance, coords, name, bone)
                        local Player = QBCore.Functions.GetPlayerData()
                        return Player.job and Player.job.name == Config.JobName and Player.job.onduty
                    end,
                    onSelect = function()
                        exports['sv_taxi']:CancelJob()
                    end
                }
            }
        })

        if Config.EnableDebug then
            print('^2[SV_TAXI]^7 ox_target zone created successfully: ' .. stand.name)
        end
    end
end)

-- Get quick spawn vehicle options
function GetQuickSpawnOptions(spawnCoords)
    local options = {}

    lib.callback('sv_taxi:getVehicles', false, function(vehicles)
        if vehicles and type(vehicles) == 'table' then
            for _, vehicle in ipairs(vehicles) do
                if vehicle.unlocked then
                    table.insert(options, {
                        title = vehicle.label,
                        description = ('Rank %d Required • %.0f%% Fare Multiplier'):format(vehicle.rank, vehicle.multiplier * 100),
                        icon = 'fa-solid fa-car',
                        onSelect = function()
                            lib.callback('sv_taxi:spawnVehicle', false, function(allowed)
                                if allowed then
                                    SpawnTaxiVehicle(vehicle.model, spawnCoords)
                                end
                            end, vehicle.model, spawnCoords)
                        end
                    })
                end
            end
        else
            table.insert(options, {
                title = 'No Vehicles Available',
                description = 'Unable to load vehicles',
                icon = 'fa-solid fa-exclamation-triangle',
                disabled = true
            })
        end
    end)

    Wait(500)
    return options
end
