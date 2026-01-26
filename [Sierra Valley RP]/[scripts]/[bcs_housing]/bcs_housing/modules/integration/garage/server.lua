function RegisterGarage(homeId, name, garageId, data)
    local coords = data.coords

    if IsResourceStarted('qbx_garages') then
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
        local types = data.type or {}
        local garageType = 'car' -- default type
        local totalTypes = 0

        for _ in pairs(Config.Garage.types) do
            totalTypes += 1
        end

        if #types < totalTypes then
            for i = 1, #types do
                for k, v in pairs(category) do
                    for j = 1, #v do
                        if types[i] == v[j] then
                            garageType = k
                            break
                        end
                    end
                end
            end
        end

        exports.qbx_garages:RegisterGarage(homeId .. garageId, {
            label = name,
            vehicleType = garageType,
            states = 1,
            canAccess = function(source)
                local player = exports.qbx_core:GetPlayer(source)
                return exports[GetCurrentResourceName()]:HasKey(homeId, player.PlayerData.citizenid)
            end,
            accessPoints = {
                {
                    coords = vec4(coords.x, coords.y, coords.z, coords.w),
                    spawn = vec4(coords.x, coords.y, coords.z, coords.w)
                }
            }
        })
    elseif IsResourceStarted('vms_garagesv2') then
        exports["vms_garagesv2"]:registerHousingGarage(
            garageId,
            name,
            homeId,
            coords,
            1
        )
    elseif IsResourceStarted('ZSX_Garages') then
        local garageCoords = vector4(coords.x, coords.y, coords.z, coords.w)
        local isPrivate = true                       -- sets that this garage should be whitelisted
        local privateType = 'player'                 -- sets that whitelisted type should select players
        local privateData = Homes[homeId]:GetOwner() -- or local privateData = {xPlayer.identifier, xPlayer2.identifier} etc.
        local garagePositions = {}
        table.insert(garagePositions, {
            coords = table.unpack(garageCoords)
        })
        exports['ZSX_Garages']:AddTempGarage(houseData.name, houseData.label, isPrivate, privateType, privateData,
            garagePositions)
    end
end

function DeleteGarage(homeId, name, garageId)
    if IsResourceStarted('qbx_garages') then
        exports.qbx_garages:DeleteGarage(homeId .. garageId)
    end
end
