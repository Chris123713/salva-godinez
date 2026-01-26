if GetConvar('qbx_vehiclekeys:enableBridge', 'true') ~= 'true' then return end

function CreateQbExport(name, cb)
    AddEventHandler(('__cfx_export_qb-vehiclekeys_%s'):format(name), function(setCB)
        setCB(cb)
    end)
end

function GetVehiclesFromPlate(plate)
    local attempts = 10
    local interval = 50
    local vehEntityFromPlate = {}

    for a = 1, attempts do
        local vehicles = GetAllVehicles()
        vehEntityFromPlate = {}

        for i = 1, #vehicles do
            local vehicle = vehicles[i]
            local vehPlate = qbx.getVehiclePlate(vehicle) or GetVehicleNumberPlateText(vehicle)
            if plate == vehPlate then
                vehEntityFromPlate[#vehEntityFromPlate + 1] = vehicle
            end
        end

        if #vehEntityFromPlate > 0 then
            break
        end

        Wait(interval)
    end

    return vehEntityFromPlate
end