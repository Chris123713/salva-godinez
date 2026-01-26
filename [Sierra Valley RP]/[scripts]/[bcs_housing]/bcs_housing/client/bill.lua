if not Config.Bill.enabled then return end

HomeWater = {}
HomeElectricity = {}
local waterOffsets = {
    ['v_res_mbath'] = vector3(0.0, 0.8, -0.35),
    ['apa_mp_h_bathtub_01'] = vector3(0.0, 0.7, -0.35),
}

function LoadBill(homeId, aptId)
    local bill = lib.callback.await('Housing:server:GetBill', source, homeId, aptId)
    for k, v in pairs(bill) do
        if v >= Config.Bill[k].limit then
            Config.Bill[k].OnLimitReached(homeId, aptId)
        end
    end
end

function UnloadBill(homeId, aptId)
    local bill = lib.callback.await('Housing:server:GetBill', source, homeId, aptId)

    for k, v in pairs(bill) do
        if v >= Config.Bill[k].limit then
            Config.Bill[k].Reset(homeId, aptId)
        end
    end
end

RegisterNetEvent('Housing:client:UpdateBill', function(homeId, bill)
    for k, v in pairs(bill) do
        if v >= Config.Bill[k].limit then
            Config.Bill[k].OnLimitReached(homeId)
        end
    end
end)

RegisterNUICallback('getHomeBills', function(data, cb)
    local bill = lib.callback.await('Housing:server:GetBill', source, data.id)
    local dataCb = {}

    for k, v in pairs(bill) do
        dataCb[#dataCb + 1] = {
            label = Config.Bill[k].label,
            limit = Config.Bill[k].limit,
            amount = v,
            percent = math.min((v / Config.Bill[k].limit) * 100, 100),
            name = k
        }
    end
    cb(dataCb)
end)

RegisterNUICallback('payHomeBill', function(data, cb)
    cb(lib.callback.await('Housing:server:PayBill', source, data.name, data.id))
end)

function WaterHandler(entity, homeId, isArea, furniture)
    local home = Homes[homeId]
    local homeCoords = GetCenterPoint(home, isArea)

    RemoveTargetEntity(entity, "water_" .. homeId .. entity)
    local options = {
        {
            icon = "fas fa-tint",
            label = "Use Water",
            action = function()
                if HomeWater[homeId] then
                    Notify(locale('water_supply'), locale('water_supply_off'), "error", 3000)
                    return
                end

                lib.requestNamedPtfxAsset("core")
                UseParticleFxAssetNextCall("core")

                local coords = {
                    x = homeCoords.x + furniture.coords.x + waterOffsets[furniture.model].x,
                    y = homeCoords.y + furniture.coords.y + waterOffsets[furniture.model].y,
                    z = homeCoords.z + furniture.coords.z + waterOffsets[furniture.model].z,
                }
                local particles = {}

                for _ = 1, 5, 1 do
                    local particle = StartParticleFxLoopedAtCoord("ent_sht_water", coords.x, coords.y,
                        coords.z + 1.2, 0.0,
                        0.0, 0.0, 1.0, false, false, false, false)
                    table.insert(particles, particle)
                    Wait(3000)
                end

                for i = 1, #particles, 1 do
                    StopParticleFxLooped(particles[i], false)
                end
            end
        },
    }

    if furniture.model == 'v_res_mbath' or furniture.model == 'apa_mp_h_bathtub_01' then
        table.insert(options,
            {
                icon = "fas fa-chair",
                label = "Sit in Bathtub",
                action = function()
                    local ped = PlayerPedId()


                    local sitCoords = {
                        x = homeCoords.x + furniture.coords.x,
                        y = homeCoords.y + furniture.coords.y,
                        z = homeCoords.z + furniture.coords.z + 0.2,
                    }

                    SetEntityCoords(ped, sitCoords.x, sitCoords.y, sitCoords.z, false, false, false, true)
                    local heading = GetEntityHeading(entity)
                    SetEntityHeading(ped, heading - 180)
                    lib.playAnim(cache.ped, "anim@amb@business@bgen@bgen_no_work@", "sit_phone_phoneputdown_idle_nowork",
                        8.0, 8.0, -1, 1)

                    CreateThread(function()
                        while true do
                            Wait(0)
                            if IsControlJustPressed(0, 38) then -- E
                                ClearPedTasks(ped)
                                ClearPedTasksImmediately(ped)
                                break
                            end
                        end
                    end)
                end
            })
    end

    AddTargetEntity("water_" .. homeId .. entity, entity, {
        options = options,
        distance = 2.0,
    })
end
