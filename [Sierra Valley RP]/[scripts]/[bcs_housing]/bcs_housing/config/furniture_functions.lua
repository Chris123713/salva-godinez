Config = Config or {}

Config.FurnitureFunctions = {
    ['computer'] = function(entity, homeId, isArea, furniture)
        print(entity, homeId, isArea, json.encode(furniture, { indent = true }))
    end,
    ['storage'] = function(entity, homeId, isArea, furniture)
        local DEFAULT_ZONE_SIZE = vec3(1.5, 1.5, 2.5)
        local home = Homes[homeId]
        if home then
            -- if home:GetStorage(furniture.identifier) then
            --     return
            -- end

            local slots = FurnitureModelList[furniture.model] and
                FurnitureModelList[furniture.model].slots or Config.FurnitureStorage.slots
            local weight = FurnitureModelList[furniture.model] and
                FurnitureModelList[furniture.model].weight or Config.FurnitureStorage.weight
            if Config.target then
                RemoveTargetEntity(entity, "Open Storage")
                AddTargetEntity("storage:" .. homeId .. ":" .. furniture.identifier, entity, {
                    options = {
                        {
                            identifier = "storage:" .. homeId .. ":" .. furniture.identifier,
                            owner = home.properties.owner,
                            home = homeId,
                            aptId = LocalPlayer.state.CurrentApartment,
                            event = "Housing:Storage",
                            icon = "fas fa-box-open",
                            label = "Open Storage",
                            slots = slots,
                            weight = weight
                        },
                    },
                    distance = 3.5,
                })
            else
                if home.zones.storages[furniture.identifier] then
                    home.zones.storages[furniture.identifier]:remove()
                end
                local storage = {
                    identifier = "storage:" .. homeId .. ":" .. furniture.identifier,
                    owner = home.properties.owner,
                    aptId = LocalPlayer.state.CurrentApartment,
                    home = homeId,
                    slots = furniture.slot or Config.DefaultSlots,
                }
                local min, max = GetModelDimensions(GetEntityModel(entity))
                local size = max + DEFAULT_ZONE_SIZE

                home.zones.storages[furniture.identifier] = lib.zones.box({
                    name = furniture.identifier,
                    coords = GetEntityCoords(entity),
                    debug = Config.debug,
                    size = size,
                    rotation = GetEntityHeading(entity),
                    onEnter = function()
                        inZone = true
                        StoragePrompt(storage)
                    end,
                    onExit = ExitZone
                })
            end
        end
    end,
    ['door'] = function(entity, homeId, isArea, furniture)
        debugPrint(entity, homeId, isArea, json.encode(furniture, { indent = true }))
        FreezeEntityPosition(entity, false)
    end,
    ['light_switch'] = function(entity, homeId, isArea, furniture)
        local home = Homes[homeId]
        if home then
            local data = FindEntitySetData(home:GetEntryCoords())
            if Config.target then
                local light = furniture.light or entity
                RemoveTargetEntity(entity, "Turn on/off light")
                AddTargetEntity("lightswitch:" .. homeId .. ":" .. light, entity, {
                    options = {
                        {
                            icon = "fas fa-box-open",
                            label = "Turn on/off light",
                            action = function()
                                if data and next(data) then
                                    local interiorId = GetInteriorFromEntity(entity)
                                    local active = IsInteriorEntitySetActive(interiorId, light)
                                    exports.bob74_ipl:SetIplPropState(interiorId, light, not active, true)
                                else
                                    if not Config.Bill.enabled then return end
                                    if HomeElectricity[homeId] then
                                        return Notify(locale('electricity_supply'), locale('electricity_supply_off'),
                                        "error", 3000)
                                    end
                                    home.electricity = not home.electricity
                                    SetArtificialLightsState(home.electricity)
                                end
                            end
                        },
                    },
                    distance = 3.5,
                })
            end
        end
    end,
    ['bell'] = function(entity, homeId, isArea, furniture)
        if Config.target then
            RemoveTargetEntity(entity, "Bell")
            AddTargetEntity("bell:" .. homeId, entity, {
                options = {
                    {
                        icon = "fas fa-bell",
                        label = "Door Bell",
                        action = function()
                            RingBell(entity, homeId)
                        end
                    },
                },
                distance = 2.0,
            })
        end
    end,
    ['water'] = function(entity, homeId, isArea, furniture)
        if Config.Bill.enabled then
            WaterHandler(entity, homeId, isArea, furniture)
        end
    end,
}
