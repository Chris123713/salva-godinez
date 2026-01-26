local function IsVehicleAllowedToPark(vehicle, garageType)
    local class = GetVehicleClass(vehicle)
    if type(garageType) == 'table' then
        for j = 1, #garageType do
            for i = 1, #VehicleTypes[garageType[j]].class, 1 do
                if class == VehicleTypes[garageType[j]].class[i] then
                    return true
                end
            end
        end
    else
        for i = 1, #VehicleTypes[garageType].class, 1 do
            if class == VehicleTypes[garageType].class[i] then
                return true
            end
        end
    end
    return false
end

function GaragePrompt(data, identifier, garageType, garageId)
    CreateThread(function()
        local home = Homes[identifier]
        local coords = home.garages[garageId].coords
        coords = vec4(coords.x, coords.y, coords.z, coords.w)

        if home.properties.complex ~= 'Apartment' then
            debugPrint("[GaragePrompt]", "Garage of owned house " .. home.properties.owner)
        end
        if home.keys:HasKey(GetIdentifier(), 'Garage') or home:isTenant('garage') or (Apartments[home.identifier] and Apartments[home.identifier]:OwnApartment()) then
            if cache.vehicle then
                HelpText(true, locale("prompt_store_vehicle"))
            else
                HelpText(true, locale("prompt_open_garage"))
            end
            while inZone do
                ::continue::
                Wait(2)
                if IsControlJustReleased(0, 38) then
                    if cache.vehicle and not IsVehicleAllowedToPark(cache.vehicle, garageType) then
                        Notify(locale('housing'), locale('vehicle_not_allowed'), 'error', 3000)
                        goto continue
                    end

                    HelpText(false)
                    if IsResourceStarted("garage_insurance") then
                        if cache.vehicle then
                            exports["garage_insurance"]:storeHouseGarage(data.properties.name)
                        else
                            exports["garage_insurance"]:openHouseGarage(data.properties.name, data.properties.data
                                .garage)
                        end
                    elseif IsResourceStarted("jg-advancedgarages") then
                        local category = {
                            car = {
                                "mo", "car", "bi"
                            },
                            air = {
                                "he", "pl"
                            },
                            sea = {
                                "bo"
                            }
                        }

                        local vehicleType

                        for i = 1, #garageType do
                            for k, v in pairs(category) do
                                for j = 1, #v do
                                    if garageType[i] == v[j] then
                                        vehicleType = k
                                        break
                                    end
                                end
                            end
                        end

                        if not vehicleType then
                            print(('[^3HOUSING^0] ^3 VehicleType not found! Home %s garageId %s'):format(home.identifier,
                                garageId))
                            goto continue
                        end

                        local id = ('%s:%s'):format(home.identifier, garageId)

                        if cache.vehicle then
                            TriggerEvent("jg-advancedgarages:client:store-vehicle", id, vehicleType)
                        else
                            TriggerEvent("jg-advancedgarages:client:open-garage", id, vehicleType, coords)
                        end
                    elseif IsResourceStarted("MojiaGarages") then
                        if cache.vehicle then
                            TriggerEvent("MojiaGarages:client:storeVehicle")
                        else
                            TriggerEvent("MojiaGarages:client:openGarage")
                        end
                    elseif IsResourceStarted("okokGarage") then
                        if cache.vehicle then
                            TriggerEvent("okokGarage:StoreVehiclePrivate")
                        else
                            TriggerEvent("okokGarage:OpenPrivateGarageMenu", GetEntityCoords(PlayerPedId()),
                                GetEntityHeading(PlayerPedId()))
                        end
                    elseif IsResourceStarted("rhd_garage") then
                        if cache.vehicle then
                            exports.rhd_garage:storeVehicle({ garage = data.properties.name, type = { 'car', 'motorcycle', 'others' }, })
                        else
                            exports.rhd_garage:openMenu({
                                garage = data.properties.name,
                                type = { 'car', 'motorcycle', 'others' },
                                spawnpoint = { coords }
                            })
                        end
                    elseif IsResourceStarted("loaf_garage") then
                        if cache.vehicle then
                            exports.loaf_garage:StoreVehicle("property", cache.vehicle)
                        else
                            exports.loaf_garage:BrowseVehicles("property", coords)
                        end
                    elseif IsResourceStarted('fmid_garasi') then
                        data.label = data.properties.name
                        local grs = lib.callback.await('fmid_garasi:getgrs', false, 'lokasi')
                        if grs?[data.properties.name] then
                            TriggerEvent('fmid_garasi:aksesGarasi', data.properties.name)
                        else
                            local saveCustomGarage = lib.callback.await('fmid_garasi:addCustomGarasi', false,
                                data.properties.name, data)
                            TriggerEvent('fmid_garasi:aksesGarasi', data.properties.name)
                        end
                        -- elseif IsResourceStarted("cd_garage") then
                        --     if cache.ped then
                        --         TriggerEvent("cd_garage:StoreVehicle_Main", 1, false)
                        --     else
                        --         ---@diagnostic disable-next-line
                        --         SetEntityCoords(PlayerPedId(), ToVector3(coords) - vector3(0.0, 0.0, 1.0))
                        --         SetEntityHeading(PlayerPedId(), coords.w)
                        --         Wait(50)
                        --         TriggerEvent("cd_garage:PropertyGarage", "quick")
                        --     end
                    elseif IsResourceStarted('codem-garage') then
                        if cache.vehicle then
                            TriggerEvent("codem-garage:storeVehicle", 'House Garage')
                        else
                            TriggerEvent("codem-garage:openHouseGarage")
                        end
                    elseif IsResourceStarted('ak47_qb_garage') then
                        if cache.vehicle then
                            TriggerEvent("ak47_qb_garage:housing:storevehicle", data.properties.name, 'car')
                        else
                            TriggerEvent("ak47_qb_garage:housing:takevehicle", data.properties.name, 'car')
                        end
                    elseif IsResourceStarted("luke_garages") then
                        local garage = {
                            label = "Property - " .. data.properties.name,
                            type = "car",
                            zone = {
                                name = data.properties.name,
                                x = coords.x,
                                y = coords.y,
                                z = coords.z,
                                w = coords.w
                            },
                            spawns = { vec4(coords.x, coords.y, coords.z, coords.w) }
                        }
                        exports.luke_garages:setZone(garage)
                        if cache.vehicle then
                            TriggerEvent("luke_garages:StoreVehicle", { entity = cache.vehicle })
                        else
                            TriggerEvent("luke_garages:GetOwnedVehicles")
                        end
                    elseif IsResourceStarted('mGarage') then
                        local GarageId = data.properties.name
                        if cache.vehicle then
                            exports['mGarage']:SaveCar({
                                name = GarageId,
                                cartype = { 'automobile', 'bike' },
                                entity = cache.vehicle,
                            })
                        else
                            exports['mGarage']:OpenGarage({
                                garagetype = 'garage',
                                intocar    = true,
                                carType    = { 'automobile', 'bike' },
                                name       = GarageId,
                                spawnpos   = {
                                    coords
                                },
                            })
                        end
                    elseif IsResourceStarted("esx_advancedgarage") then
                        if cache.vehicle then
                            local vehicle = cache.vehicle
                            local vehProps = ESX.Game.GetVehicleProperties(vehicle)
                            exports.esx_advancedgarage:setGarage({
                                Spawner = ToVector3(coords),
                                Heading = coords.w
                            })
                            TriggerServerCallback("esx_advancedgarage:storeVehicle", function(valid)
                                if valid then
                                    TriggerServerEvent("esx_advancedgarage:setVehicleState", vehProps.plate, true)
                                    ESX.Game.DeleteVehicle(vehicle)
                                end
                            end, vehProps, data.properties.name)
                        else
                            exports.esx_advancedgarage:setGarage({
                                Spawner = ToVector3(coords),
                                Heading = coords.w
                            })
                            exports.esx_advancedgarage:OpenGarageMenu("civ", "cars")
                        end
                    elseif IsResourceStarted("esx_jb_eden_garage2") then
                        local garage = {
                            SpawnPoint = {
                                Pos = { x = coords.x, y = coords.y, z = coords.z },
                                Heading = coords.w
                            },
                            DeletePoint = ToVector3(coords)
                        }
                        if cache.vehicle then
                            TriggerEvent("esx_eden_garage:StockVehicleMenu", "personal", data.properties.name)
                        else
                            TriggerEvent("esx_eden_garage:ListVehiclesMenu", garage, "personal", data.properties.name)
                        end
                    elseif IsResourceStarted('vms_garagesv2') then
                        exports['vms_garagesv2']:enterHouseGarage()
                    elseif IsResourceStarted('tgiann-realparking') then
                        if cache.vehicle then
                            exports["tgiann-realparking"]:ParkGarage('home:' .. identifier, garageId, true)
                        else
                            exports["tgiann-realparking"]:OpenGarage('home:' .. identifier, garageId, true)
                        end
                    end
                    break
                end
            end

            while IsNuiFocused() do Wait(100) end
            Wait(1000)

            if inZone then
                local updatedData = GetHomeObject(identifier)
                GaragePrompt(updatedData, identifier, garageType, garageId)
            end
        end
    end)
end
