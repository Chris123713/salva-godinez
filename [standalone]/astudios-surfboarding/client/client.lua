local QBCore = exports['qb-core']:GetCoreObject()
local surfBoard = nil
local currentSurfer = nil

RegisterNetEvent('astudios-surfboarding:client:use', function()
    local playerPed = PlayerPedId()

    if not DoesEntityExist(surfBoard) then
        local surfBoardModel = Config.BoardItem
        RequestModel(surfBoardModel)
        while not HasModelLoaded(surfBoardModel) do
            Wait(0)
        end
        local playerPedCoords = GetEntityCoords(playerPed)
        TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
        QBCore.Functions.Progressbar("placing_board", Config.Language.Progressbar['placing'], 2000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
        }, {}, {}, {}, function() -- Done
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            surfBoard = CreateVehicle(surfBoardModel, playerPedCoords.x, playerPedCoords.y, playerPedCoords.z + 1.0, GetEntityHeading(playerPed), true, false)
            SetVehicleOnGroundProperly(surfBoard)
            SetVehicleNumberPlateText(surfBoard, "SURF".. math.random(1111, 9999))
            SetPedIntoVehicle(playerPed, surfBoard, -1)
            SetModelAsNoLongerNeeded(surfBoardModel)
            local surfBoardPlate = GetVehicleNumberPlateText(surfBoard)
            TriggerEvent("vehiclekeys:client:SetOwner", surfBoardPlate)
            SetVehicleEngineOn(surfBoard, true, true)
            currentSurfer = playerPed
        end, function() -- Cancel
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        end)
    elseif currentSurfer == playerPed then
        TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
        QBCore.Functions.Progressbar("removing_board", Config.Language.Progressbar['removing'], 1000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
        }, {}, {}, {}, function() -- Done
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            DeleteVehicle(surfBoard)
            surfBoard = nil
            currentSurfer = nil
        end, function() -- Cancel
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        end)
    else
        if Config.NotificationType.client == "qbcore" then
            QBCore.Functions.Notify(Config.Language.Error['too_far_or_in_use'], "error")
        elseif Config.NotificationType.client == "astudios" then
            exports['astudios-notify']:notify("", Config.Language.Error['too_far_or_in_use'], 5000, 'error')
        end
    end
end)