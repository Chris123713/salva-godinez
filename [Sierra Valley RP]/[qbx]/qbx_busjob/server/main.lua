local config = require 'config.server'
local sharedConfig = require 'config.shared'

local function isPlayerNearBus(src)
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    for _, v in pairs(sharedConfig.npcLocations.locations) do
        local dist = #(coords - vec3(v.x, v.y, v.z))
        if dist < 20 then
            return true
        end
    end
    return false
end

lib.callback.register('qbx_busjob:server:spawnBus', function(source, model)
    local src = source
    local ped = GetPlayerPed(src)

    local netId = qbx.spawnVehicle({ model = model, spawnSource = ped, warp = true })
    if not netId or netId == 0 then return end
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or veh == 0 then return end

    local plate = locale('info.bus_plate') .. tostring(math.random(1000, 9999))
    SetVehicleNumberPlateText(veh, plate)
    TriggerClientEvent('vehiclekeys:client:SetOwner', source, plate)
    return netId
end)

RegisterNetEvent('qbx_busjob:server:NpcPay', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not isPlayerNearBus(src) then return DropPlayer(src, locale('error.exploit_attempt')) end

    -- Use orchestrator for dynamic pricing
    local pay = exports['sv_job_orchestrator']:GetJobPay('bus')
    local basePayment = type(pay) == 'table' and math.random(pay.min, pay.max) or math.random(300, 430)
    exports['sv_job_orchestrator']:ProcessJobPayment(src, 'bus', basePayment, 'cash', 'Bus route payment')
end)
