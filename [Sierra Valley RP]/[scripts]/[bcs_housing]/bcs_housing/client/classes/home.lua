local DEFAULT_ZONE_SIZE = vec3(1.5, 1.5, 2.5)

Home = {}

Home.__index = Home

Home.__newindex = function(self, name, fn)
    rawset(self, name, fn)
end

function Home:new(houseData)
    local self = setmetatable({}, Home)
    self.zones = {}
    self.points = {}
    self.zones.storages = {}
    self.zones.wardrobes = {}
    self.properties = houseData or {}
    if self.properties.data.garage and self.properties.data.garage.x then
        self.properties.data.garage = vec4(self.properties.data.garage.x, self.properties.data.garage.y,
            self.properties.data.garage.z, self.properties.data.garage.w + 0.1)
    end
    self.properties.storages = {}
    self.properties.wardrobes = {}
    self.properties.furniture = {}

    self.areaObjects = {}
    self.spawnedObjects = {}
    self.configuration = houseData.configuration
    self.permission = houseData.permission
    self.identifier = houseData.identifier
    self.thumbnail = houseData.thumbnail
    self.disabled = houseData.disabled or false

    self.doors = houseData.doors
    self.properties.doors = nil

    if self.properties.type == 'mlo' then
        self:InitDoors()
    end

    self.properties.configuration = nil
    self.properties.permission = nil
    self.garages = houseData.garages or {}
    self.teleports = houseData.teleports or {}
    self:InitZones()
    self.keys = Keys:new(
        self.identifier,
        houseData.keys.list,
        houseData.keys.holders
    )
    self.cctv = CCTV:new(self.identifier)

    if self.properties.data and self.properties.data.signboard then
        LoadSignboard(self.properties.data.signboard, self.properties.realestate)
    end
    return self
end

function Home:Update(houseData)
    self.properties = houseData
    self.configuration = houseData.configuration
    self.permission = houseData.permission
    self.properties.configuration = nil
    self.properties.permission = nil

    if self.properties.data.garage and self.configuration.garage then
        self:SetGarageZone()
    end
end

function Home:UpdateShell(data)
    self.properties.data.placement = data.shell
    self.properties.data.placement.w = data.heading
    self.properties.data.interior = data.heading
    TriggerServerEvent('Housing:server:UpdateShell', self.identifier, data)
end

function Home:UpdatePermission(permission)
    self.permission = permission
    TriggerServerEvent('Housing:server:SaveHomePermission', self.identifier, self.permission)
end

function Home:SaveEdit(data)
    self.properties.price = data.price
    self.properties.payment = data.payment
    if data.expiry ~= nil then
        self.properties.data.expiry = data.expiry
    end
    TriggerServerEvent('Housing:server:SaveEditHome', self.identifier, data)
    return true
end

--- Initialize data
---@param data {storages: table, wardrobes: table, furniture: table}
function Home:SetData(data, aptId)
    if not data then
        debugPrint(('[Housing Warning] Set Data failed for %s (%s)'):format(self.identifier, aptId), json.encode(data))
        return
    end
    if aptId and aptId ~= 'nil' then
        local apt = Apartments[self.identifier]:GetApartmentById(aptId)
        apt.storages = data.storages
        apt.wardrobes = data.wardrobes
        apt.furniture = data.furniture
        if apt.storages and next(apt.storages) then
            local list = {}
            for k, v in pairs(apt.storages) do
                list[#list + 1] = v
            end
            apt.storages = list
        end
    else
        self.properties.storages = data.storages
        self.properties.wardrobes = data.wardrobes
        self.properties.furniture = data.furniture
        if self.properties.storages and next(self.properties.storages) then
            local list = {}
            for k, v in pairs(self.properties.storages) do
                list[#list + 1] = v
            end
            self.properties.storages = list
        end
    end
    self:SetStoragesZone(aptId)
    local wardrobes = self.properties.complex == 'Apartment' and Apartments[self.identifier]:GetWardrobes() or
        self.properties.wardrobes
    for i = 1, #wardrobes do
        self:SetWardrobeZone(wardrobes[i], aptId)
    end
end

function Home:SetZones()
    if #self.properties.wardrobes > 0 and self.properties.type == 'mlo' then
        for i = 1, #self.properties.wardrobes do
            self:SetWardrobeZone(self.properties.wardrobes[i])
        end
    end
end

function Home:InitZones()
    if self.configuration.garage and self.garages then
        self:SetGarageZone()
    end
    if self.properties.area and self.properties.area.points then
        self:SetAreaZone()
    end
    if self.teleports and self.properties.complex ~= 'Apartment' then
        self:SetTeleports()
    end
end

function Home:InitDoors()
    for i = 1, #self.doors do
        AddDoor(self.identifier, self.doors[i])
    end
end

function Home:DeleteDoors()
    for i = 1, #self.doors do
        RemoveDoor(self.identifier, self.doors[i])
    end
end

function Home:SetTeleports()
    Wait(0)
    for i = 1, #self.teleports do
        SetTeleport(self, self.teleports[i])
    end
end

function Home:DeleteTeleports()
    for i = 1, #self.teleports do
        DeleteTeleport(self, self.teleports[i])
    end
end

function Home:AddTeleport(data)
    table.insert(self.teleports, data)
    self:SetTeleports()
end

function Home:DeleteTeleport(name)
    for i = 1, #self.teleports do
        if self.teleports[i].name == name then
            DeleteTeleport(self, self.teleports[i])
            self:SetTeleports()
            break
        end
    end
end

function Home:MoveTeleport(data)
    for i = 1, #self.teleports do
        if self.teleports[i].name == data.name then
            for k, v in pairs(data) do
                self.teleports[i][k] = v
            end
            self:SetTeleports()
            break
        end
    end
end

function Home:ToggleLockTeleport(name, lock)
    for i = 1, #self.teleports do
        if self.teleports[i].name == name then
            self.teleports[i].locked = lock
            self:SetTeleports()
            break
        end
    end
end

function Home:AddGarage(data)
    table.insert(self.garages, data)
    self:SetGarageZone()
end

function Home:DeleteGarage(data)
    for i = 1, #self.garages do
        if self.garages[i].name == data.name then
            if self.garages[i].zone then
                self.garages[i].zone:remove()
                self.garages[i].zone = nil
            end
            if Config.EnableMarkers.enable then
                if self.garages[i].point then
                    self.garages[i].point:remove()
                    self.garages[i].point = nil
                end
            end
            table.remove(self.garages, i)
            break
        end
    end
    self:SetGarageZone()
end

function Home:MoveGarage(data)
    for i = 1, #self.garages do
        if self.garages[i].name == data.name then
            self.garages[i].coords = data.coords
            break
        end
    end
    self:SetGarageZone()
end

function Home:DeleteGarages()
    if self.garages then
        for i = 1, #self.garages do
            self:DeleteGarage(self.garages[i])
        end
        self.garages = {}
    end
end

local NONPROMPT_GARAGES = {
    ['qb-garages'] = true,
    ['cd_garage'] = true,
    ['qbx_garages'] = true,
    ['op-garages'] = true
}

function Home:SetGarageZone()
    local garages = self.garages
    for i, garage in pairs(garages) do
        local coords = garage.coords
        coords = vec4(coords.x, coords.y, coords.z, coords.w)

        local garageId = ("%s_%s"):format(self.properties.name, garage.name)

        if IsResourceStarted('qb-garages') or IsResourceStarted('cd_garage') then
            local houseInfo = {
                label = self.properties.name,
                type = 'house',
                takeVehicle = coords
            }
            TriggerEvent('qb-garages:client:addHouseGarage', self.identifier, houseInfo)
        elseif IsResourceStarted('op-garages') then
            local PrivatePlayersList = GetPlayerServerId(PlayerId())
            local Coords = {
                CenterOfZone = coords,
                AccessPoint = vec4(0.0, 0.0, 0.0, 0.0)
            }
            exports['op-garages']:ClientaddTempPrivateGarage(garageId, "car", Coords, 5, PrivatePlayersList)
        end

        if garage.zone then
            garage.zone:remove()
            garage.zone = nil
        end


        local size = vec3(3, 3, 2.5)

        if garage.type then
            for _, v in ipairs(garage.type) do
                if v == "bo" then
                    size = vec(10, 10, 3.5)
                    break
                end
            end
        end

        garage.zone = lib.zones.box({
            coords = ToVector3(coords),
            size = size,
            rotation = coords.w,
            debug = Config.debug,
            onEnter = function()
                TriggerEvent('qb-garages:client:setHouseGarage', self.identifier,
                    self:isKeyOwner() or self:isTenant('garage'))
                TriggerEvent('advancedgarages:SetShellGarageData', self.identifier,
                    self:isKeyOwner() or self:isTenant('garage'))
                inZone = true
                for k, v in pairs(NONPROMPT_GARAGES) do
                    if IsResourceStarted(k) then
                        return
                    end
                end
                if (self:isKeyOwner() or self:isTenant('garage')) then
                    TriggerEvent('MojiaGarages:client:currentGarage', true, garageId)
                    GaragePrompt(self, self.identifier, garage.type, i)
                else
                    TriggerEvent('MojiaGarages:client:currentGarage', true, garageId, true)
                end
            end,
            onExit = function()
                TriggerEvent('MojiaGarages:client:currentGarage', false, nil)
                ExitZone()
            end
        })

        if Config.EnableMarkers.enable then
            if garage.points then
                garage.points:remove()
            end

            garage.points = lib.points.new({
                coords = ToVector3(garage),
                distance = 3,
                nearby = function()
                    DrawMarker(Config.EnableMarkers.type, ToVector3(garage), 0.0, 0.0, 0.0, 0, 0.0,
                        0.0, Config.EnableMarkers.size.x, Config.EnableMarkers.size.y, Config.EnableMarkers.size.z,
                        Config.EnableMarkers.color.r, Config.EnableMarkers.color.g, Config.EnableMarkers.color.b, 100,
                        false, true, 2, false, false, false, false)
                end
            })
        end
    end
end

function Home:AddWardrobe(wardrobe, aptId)
    if aptId then
        Apartments[self.identifier]:AddWardrobe(wardrobe, aptId)
    else
        self.properties.wardrobes[#self.properties.wardrobes + 1] = wardrobe
    end
    if CurrentHome.identifier == self.identifier and (not aptId or aptId == LocalPlayer.state.CurrentApartment) then
        self:SetWardrobeZone(wardrobe, aptId)
    end
end

function Home:RemoveWardrobe(name, aptId)
    if aptId then
        Apartments[self.identifier]:RemoveWardrobe(name, aptId)
    else
        for i = 1, #self.properties.wardrobes do
            if self.properties.wardrobes[i].name == name then
                table.remove(self.properties.wardrobes, i)
                break
            end
        end
    end
    RemoveTargetZone(self.identifier .. '-wardrobe-' .. name)
    if self.zones.wardrobes[name] then
        self.zones.wardrobes[name]:remove()
        self.zones.wardrobes[name] = nil
    end
end

function Home:SetWardrobeZone(wardrobe, aptId)
    if Config.target then
        RemoveTargetZone(self.identifier .. '-wardrobe-' .. wardrobe.name)
        AddTargetBoxZone(self.identifier .. '-wardrobe-' .. wardrobe.name, {
            coords = vec3(wardrobe.coords.x, wardrobe.coords.y, wardrobe.coords.z + 1),
            length = 2.0,
            width = 2.0,
            heading = wardrobe.coords.w,
            debugPoly = Config.debug,
            minZ = wardrobe.coords.z - 1.0,
            maxZ = wardrobe.coords.z + 2.0
        }, {
            options = {
                {
                    icon = "fa-solid fa-shirt",
                    label = locale('open', locale('wardrobe')),
                    action = function()
                        OpenWardrobe(self.identifier)
                    end,
                    canInteract = function()
                        return (self.keys:HasKey(GetIdentifier(), 'Wardrobe', aptId) or self:isTenant('wardrobe')) and
                            CurrentHome and
                            CurrentHome.identifier == self.identifier and
                            (not aptId or LocalPlayer.state.CurrentApartment == aptId)
                    end
                },
            },
            distance = 3.5
        })
    else
        if self.zones.wardrobes[wardrobe.name] then
            self.zones.wardrobes[wardrobe.name]:remove()
        end
        self.zones.wardrobes[wardrobe.name] = lib.zones.box({
            coords = vec3(wardrobe.coords.x, wardrobe.coords.y, wardrobe.coords.z + 1),
            size = DEFAULT_ZONE_SIZE,
            rotation = wardrobe.coords.w,
            debug = Config.debug,
            onEnter = function()
                inZone = true
                if self.keys:HasKey(GetIdentifier(), 'Wardrobe', aptId) then
                    WardrobePrompt(self)
                end
            end,
            onExit = ExitZone
        })
    end
    if Config.EnableMarkers.enable then
        if not self.points.wardrobes then
            self.points.wardrobes = {}
        end
        if self.points.wardrobes[wardrobe.name] then
            self.points.wardrobes[wardrobe.name]:remove()
        end
        self.points.wardrobes[wardrobe.name] = lib.points.new({
            coords = ToVector3(wardrobe.coords),
            distance = 3,
            nearby = function()
                DrawMarker(Config.EnableMarkers.type,
                    vec3(wardrobe.coords.x, wardrobe.coords.y, wardrobe.coords.z + 1), 0.0, 0.0, 0.0, 0, 0.0, 0.0,
                    Config.EnableMarkers.size.x, Config.EnableMarkers.size.y,
                    Config.EnableMarkers.size.z, Config.EnableMarkers.color.r,
                    Config.EnableMarkers.color.g, Config.EnableMarkers.color.b, 100, false, true,
                    2, false, false, false, false)
            end
        })
    end
end

function Home:SetAreaZone()
    if self.zones.areaZone then
        self.zones.areaZone:remove()
        self.zones.areaZone = nil
    end
    local area = self.properties.area
    for k, v in pairs(area.points) do
        area.points[k] = vec3(v.x, v.y, self.properties.entry.z)
    end
    self.zones.areaZone = lib.zones.poly({
        name = 'area-' .. self.properties.name,
        points = area.points,
        thickness = area.height,
        debug = Config.debug,
        onEnter = function()
            if (CurrentHome and next(CurrentHome) == nil or not Homes[CurrentHome.identifier]) then
                inside = true
                CurrentHome = self
                LocalPlayer.state:set('CurrentHome', self)
                LocalPlayer.state:set('isInsideArea', true)
                local aptId = LocalPlayer.state.CurrentApartment
                local data = lib.callback.await('Housing:server:GetData', false, self.identifier, aptId)
                -- Initialize furniture, storage and wardrobes
                self:SetData(data, aptId)
                self:SpawnFurnitures(true)
                if self.properties.complex == 'mlo' then
                    local interior = GetCustomizeIPL(self.identifier, true)

                    if interior then
                        interior:Load()
                    end
                end

                TriggerEvent('Housing:client:OnEnterArea', self.identifier)
                TriggerServerEvent('Housing:server:OnEnterArea', self.identifier)
                debugPrint('[AreaZone]', 'Player is inside MLO of ' .. self.properties.name)
            end
        end,
        onExit = function()
            self:DeleteFurnitures(true)
            LocalPlayer.state:set('isInsideArea', false)
            TriggerEvent('Housing:client:OnExitArea', self.identifier)
            if CurrentHome and CurrentHome.identifier == self.identifier and not LocalPlayer.state.isInsideHome then
                TriggerServerEvent('Housing:server:OnExitArea', self.identifier)
                LocalPlayer.state:set('CurrentHome', {})
                CurrentHome = {}
                inside = false
                isRaiding = false
                debugPrint('[AreaZone]', 'Player is outside MLO of ' .. self.properties.name)
            end
        end
    })
end

function Home:MoveStorage(id, coords, area)
    if self.properties.complex == 'Apartment' then
        local aptId = LocalPlayer.state.CurrentApartment
        if aptId then
            local storage = Apartments[self.identifier]:MoveStorage(id, coords, area)
            TriggerServerEvent('Housing:server:UpdateStorage', { homeId = self.identifier, aptId = aptId }, storage,
                true)
        end
    else
        for i = 1, #self.properties.storages do
            local storage = self.properties.storages[i]
            if storage.id == id then
                self.properties.storages[i].coords = coords
                self.properties.storages[i].area = area
                TriggerServerEvent('Housing:server:UpdateStorage', self.identifier, self.properties.storages[i], true)
                break
            end
        end
    end
end

function Home:SaveStorages(storages)
    for i = 1, #storages do
        for j = 1, #self.properties.storages do
            if self.properties.storages[j].id == storages[i].id then
                self.properties.storages[j].weight = storages[i].weight
                self.properties.storages[j].slots = storages[i].slots
            end
        end
    end
end

function Home:AddStorage(id, weight, slots, area, coords)
    if not self:GetStorage(id) then
        local data = {
            id = id or math.random(100, 999),
            coords = coords,
            weight = weight,
            slots = slots,
            type = id and 'furniture' or 'zone',
            area = area
        }
        if self.properties.complex == 'Apartment' then
            local aptId = LocalPlayer.state.CurrentApartment
            if aptId then
                TriggerServerEvent('Housing:server:UpdateStorage', { homeId = self.identifier, aptId = aptId }, data)
            end
        else
            self.properties.storages[#self.properties.storages + 1] = data
            TriggerServerEvent('Housing:server:UpdateStorage', self.identifier, data)
        end
    end
end

function Home:GetStorage(id)
    if self.properties.complex == 'Apartment' then
        local storages = Apartments[self.identifier]:GetStorages()
        if storages then
            for i = 1, #storages do
                if tonumber(storages[i].id) == tonumber(id) then
                    return storages[i]
                end
            end
        end
    elseif self.properties.storages then
        for i = 1, #self.properties.storages do
            if tonumber(self.properties.storages[i].id) == tonumber(id) then
                return self.properties.storages[i]
            end
        end
    end
end

function Home:GetStorages()
    if self.properties.complex == 'Apartment' then
        return Apartments[self.identifier]:GetStorages()
    else
        return self.properties.storages
    end
end

function Home:DeleteStorage(identifier, aptId)
    if identifier then
        if aptId and self.properties.complex == 'Apartment' then
            Apartments[self.identifier]:DeleteStorage(identifier, aptId)
        else
            for i = 1, #self.properties.storages do
                if self.properties.storages[i].id == identifier then
                    table.remove(self.properties.storages, i)
                    break
                end
            end
        end
        local zoneId = "storage:" .. self.identifier .. ":" .. identifier .. (aptId and ':' .. aptId or '')
        if Config.target then
            RemoveTargetZone(zoneId)
        else
            if self.zones.storages[zoneId] then
                self.zones.storages[zoneId]:remove()
                self.zones.storages[zoneId] = nil
            end
        end
        if Config.EnableMarkers.enable and self.points.storages and self.points.storages[identifier] then
            self.points.storages[identifier]:remove()
        end
    end
end

function Home:SetStoragesZone(aptId)
    local storages = self.properties.complex == 'Apartment' and Apartments[self.identifier]:GetStorages() or
        self.properties.storages
    if not storages then return end
    for i = 1, #storages do
        local storage = storages[i]
        if not storage.coords then
            goto continue
        end
        storage.aptId = aptId
        if storage.type == 'zone' and (((self.properties.type == 'shell' or self.properties.type == 'mlo') and storage.area) or LocalPlayer.state.isInsideHome) then
            local homecoords = GetCenterPoint(self, storage.area)
            local coords = {
                x = round(storage.coords.x + homecoords.x, 4),
                y = round(storage.coords.y + homecoords.y, 4),
                z = round(storage.coords.z + homecoords.z, 4),
            }
            storage.home = self.identifier
            if Config.Inventory == 'ox_inventory' then
                storage.identifier = "storage:" .. self.identifier .. ":" .. storage.id
            else
                storage.identifier = "storage:" .. self.identifier .. ":" .. storage.id .. (aptId and ':' .. aptId or '')
            end
            storage.zoneId = "storage:" .. self.identifier .. ":" .. storage.id .. (aptId and ':' .. aptId or '')
            if Config.target then
                RemoveTargetZone(storage.zoneId)
                AddTargetBoxZone(storage.zoneId, {
                    coords = vec3(coords.x, coords.y, coords.z + 1),
                    length = 2.0,
                    width = 2.0,
                    heading = coords.w,
                    debugPoly = Config.debug,
                    minZ = coords.z - 1.0,
                    maxZ = coords.z + 2.0
                }, {
                    options = {
                        {
                            icon = "fa-solid fa-box-open",
                            label = locale('open', locale('storage')),
                            action = function()
                                storage.owner = Homes[storage.home].properties.owner
                                TriggerEvent('Housing:Storage', storage)
                            end,
                            canInteract = function()
                                return CurrentHome and CurrentHome.identifier == self.identifier and
                                    (not aptId or tonumber(LocalPlayer.state.CurrentApartment) == tonumber(aptId))
                            end
                        },
                    },
                    distance = 3.5
                })
            else
                if self.zones.storages[storage.zoneId] then
                    self.zones.storages[storage.zoneId]:remove()
                end
                self.zones.storages[storage.zoneId] = lib.zones.box({
                    coords = vec3(coords.x, coords.y, coords.z + 1.0),
                    size = DEFAULT_ZONE_SIZE,
                    debug = Config.debug,
                    rotation = 0,
                    onEnter = function()
                        inZone = true
                        StoragePrompt(storage)
                    end,
                    onExit = ExitZone
                })
            end

            if Config.EnableMarkers.enable then
                if not self.points.storages then
                    self.points.storages = {}
                end
                if self.points.storages[storage.id] then
                    self.points.storages[storage.id]:remove()
                end
                self.points.storages[storage.id] = lib.points.new({
                    coords = ToVector3(coords),
                    distance = 3,
                    nearby = function()
                        DrawMarker(Config.EnableMarkers.type, vec3(coords.x, coords.y, coords.z + 1.5),
                            0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.EnableMarkers.size.x,
                            Config.EnableMarkers.size.y, Config.EnableMarkers.size.z,
                            Config.EnableMarkers.color.r, Config.EnableMarkers.color.g,
                            Config.EnableMarkers.color.b, 100, false, true, 2, false, false, false, false)
                    end
                })
            end
        end
        ::continue::
    end
end

function Home:DeleteStoragesZone()
    -- Deleting poly zones
    for k, v in pairs(self.zones.storages) do
        self.zones.storages[k]:remove()
    end
    self.zones.storages = {}
    -- Deleting markers
    if Config.EnableMarkers.enable and self.points.storages then
        for k, v in pairs(self.points.storages) do
            self.points.storages[k]:remove()
        end
    end
end

function Home:DeleteWardrobesZone()
    -- Deleting poly zones
    for k, v in pairs(self.zones.wardrobes) do
        self.zones.wardrobes[k]:remove()
    end
    self.zones.wardrobes = {}
    -- Deleting target zones
    if Config.target then
        local wardrobes = self.properties.complex == 'Apartment' and Apartments[self.identifier]:GetWardrobes() or
            self.properties.wardrobes
        if wardrobes then
            for i = 1, #wardrobes do
                RemoveTargetZone(self.identifier .. '-wardrobe-' .. wardrobes[i].name)
            end
        end
    end
    -- Deleting marker zones
    if Config.EnableMarkers.enable and self.points.wardrobes then
        for k, v in pairs(self.points.wardrobes) do
            self.points.wardrobes[k]:remove()
        end
        self.points.wardrobes = {}
    end
end

function Home:DestroyZones()
    for key, val in pairs(self.zones) do
        if key ~= 'storages' and key ~= 'wardrobes' then
            val:remove()
        end
    end
    if Config.EnableMarkers.enable then
        for k, v in pairs(self.points) do
            if k == 'wardrobes' or k == 'storages' then
                for j, _ in pairs(self.points[k]) do
                    self.points[k][j]:remove()
                end
            elseif self.points[k] then
                self.points[k]:remove()
            end
        end
    end
    if CurrentHome.HouseEntrance then CurrentHome.HouseEntrance:remove() end
    if Config.target then RemoveTargetZone("HouseEntrance-" .. self.identifier) end
    if self.properties.complex == 'Individual' then
        Individuals[self.identifier]:DestroyZone(self.properties.name)
    elseif self.properties.complex == 'Apartment' then
        Apartments[self.identifier]:DestroyZone(self.properties.name)
    elseif self.properties.complex == 'Public' then
        Publics[self.identifier]:DestroyZone(self.properties.name)
    end
end

function Home:UpdateConfig(config)
    self.configuration = config
end

function Home:isOwned(aptId)
    if self.properties.complex == 'Apartment' then
        if aptId then
            local apt = Apartments[self.identifier]:GetApartmentById(aptId)
            return apt and apt.owner ~= nil or false
        end
    else
        return self.properties.owner ~= nil
    end
end

function Home:isOwner(aptId)
    local playerId = GetIdentifier()
    if self.properties.complex == 'Apartment' then
        if aptId then
            local apt = Apartments[self.identifier]:GetApartmentById(aptId)
            return apt and apt.owner == playerId or false
        else
            return Apartments[self.identifier]:OwnApartment()
        end
    else
        return self.properties.owner == playerId
    end
end

function Home:isKeyOwner(perm)
    local playerId = GetIdentifier()
    return self:isOwner() or self.keys:HasKey(playerId, perm)
end

function Home:isTenant(permission)
    local playerId = GetIdentifier()
    if self.properties.rent and self.properties.rent.isRented then
        if permission then
            return self.properties.rent.permission[permission] and
                (self.properties.rent.tenant and self.properties.rent.tenant == playerId)
        else
            return self.properties.rent.tenant and self.properties.rent.tenant == playerId
        end
    else
        return false
    end
end

function Home:CreateInsideEntrance(entry)
    if Config.target then
        AddTargetBoxZone("HouseEntrance-" .. self.identifier, {
            coords = entry,
            length = 2.0,
            width = 2.0,
            heading = GetEntityHeading(CurrentHome.object),
            debugPoly = Config.debug,
            minZ = entry.z - 1.0,
            maxZ = entry.z + 2.0
        }, {
            options = {
                {
                    icon = "fas fa-door-open",
                    label = locale('exit_house'),
                    action = function()
                        TriggerEvent('Housing:client:ExitHome', self.identifier)
                    end
                },
                {
                    icon = "fas fa-door-open",
                    label = locale('lock_home'),
                    action = function()
                        TriggerServerEvent('Housing:server:LockHome', self.identifier, nil,
                            LocalPlayer.state.CurrentApartment)
                    end,
                    canInteract = function()
                        return (Homes[self.identifier]:isKeyOwner() or Homes[self.identifier]:isTenant() or isPolice()) and
                            not exports[GetCurrentResourceName()]:isLocked(self.identifier)
                    end
                },
                {
                    icon = "fas fa-door-open",
                    label = locale('unlock_home'),
                    action = function()
                        TriggerServerEvent('Housing:server:LockHome', self.identifier, nil,
                            LocalPlayer.state.CurrentApartment)
                    end,
                    canInteract = function()
                        return (Homes[self.identifier]:isKeyOwner() or Homes[self.identifier]:isTenant() or isPolice()) and
                            exports[GetCurrentResourceName()]:isLocked(self.identifier)
                    end
                },
            },
            distance = 3.5
        })
    else
        CurrentHome.HouseEntrance = lib.zones.box({
            coords = entry,
            size = vec3(2.0, 2.0, 3.0),
            rotation = GetEntityHeading(CurrentHome.object),
            debug = Config.debug,
            onEnter = function()
                HelpText(true, locale("prompt_home_menu"))
                inZone = true
                local boxes = {}
                table.insert(boxes, {
                    text = { title = locale('exit_house') },
                    icon = "door-open",
                    event = "Housing:client:ExitHome",
                    args = { self.identifier }
                })
                if Homes[self.identifier]:isOwner() then
                    table.insert(boxes, {
                        text = { title = locale('manage_house') },
                        icon = "home",
                        event = "Housing:client:OpenHouseManager",
                        args = { self.identifier, true }
                    })
                end
                if Homes[self.identifier]:isKeyOwner() or Homes[self.identifier]:isTenant() or isPolice() then
                    table.insert(boxes, {
                        text = {
                            title = locale("lock_home"),
                            body = locale("lock_home_body")
                        },
                        icon = "lock",
                        server = true,
                        event = "Housing:server:LockHome",
                        args = { self.identifier, nil, LocalPlayer.state.CurrentApartment }
                    })
                end
                CreateThread(function()
                    while inZone do
                        if IsControlJustPressed(0, 38) then
                            HelpText(false)
                            TriggerEvent("Housing:client:CreateMenu", {
                                title = self.properties.name,
                                subtitle = locale('house_menu'),
                                boxes = boxes
                            })
                            break
                        end
                        Wait(0)
                    end
                end)
            end,
            onExit = function()
                HelpText(false)
                inZone = false
            end
        })
    end
end

---Spawn house furnitures
---@param isArea boolean
function Home:SpawnFurnitures(isArea)
    if self.properties.type ~= 'mlo' then
        if self.properties.area and self.zones.areaZone then
            if self.zones.areaZone.insideZone then
                isArea = true
            end
        end
    end

    local timeout = 0
    local furnitures = self:GetFurnitures()
    while not furnitures do
        Wait(100)
        furnitures = self:GetFurnitures()
        timeout = timeout + 1
        if timeout > 200 then
            print("[Housing Error]", "Timeout received", self.identifier)
            break
        end
    end
    if timeout > 200 then return end
    local center = GetCenterPoint(self, isArea)
    TriggerEvent('Housing:client:SpawnFurnitures', self, furnitures, center)
    for i = 1, #furnitures do
        local value = furnitures[i]
        if (isArea and (isArea == value.area) or self.properties.type == 'mlo') or (not isArea and not value.area) then
            debugPrint("[SpawnFurnitures]", "Spawning furniture prop: " .. value.model, json.encode(value.coords))
            local furncoords
            if self.properties.type == "shell" and not isArea then
                furncoords = GetOffsetFromEntityInWorldCoords(CurrentHome.object,
                    ToVector3(value.coords))
            else
                furncoords = center + ToVector3(value.coords)
            end
            debugPrint("[SpawnFurnitures]", json.encode(furncoords))
            local object = CreateObject(value.model, furncoords, false, false, false)
            SetEntityCoordsNoOffset(object, furncoords)
            SetEntityHeading(object, value.heading)
            local rotation = value.rotation and ToVector3(value.rotation) or
                vec3(0, 0, value.heading)
            SetEntityRotation(object, rotation)
            FreezeEntityPosition(object, true)
            debugPrint("[SpawnFurnitures]", "Furniture created: " .. object)

            if value.identifier then
                Config.FurnitureFunctions['storage'](object, self.identifier, isArea, value)
            elseif FurnitureModelList[value.model] then
                if Config.FurnitureFunctions[FurnitureModelList[value.model].type] then
                    Config.FurnitureFunctions[FurnitureModelList[value.model].type](object, self.identifier,
                        isArea, value)
                end
            else
                print(('[SpawnFurniture] Error, %s furniture does not exists within the list of furnitures'):format(
                    value.model))
            end

            if value.area then
                self.areaObjects[#self.areaObjects + 1] = {
                    object = object,
                    key = value.key
                }
                debugPrint("[SpawnFurnitures]",
                    json.encode(self.areaObjects))
            else
                self.spawnedObjects[#self.spawnedObjects + 1] = {
                    object = object,
                    key = value.key
                }
                debugPrint("[SpawnFurnitures]", json.encode(self.spawnedObjects))
            end
        end
    end
    -- Experimental qb-weed
    TriggerEvent("qb-weed:client:getHousePlants", self.identifier)
end

function Home:GetFurnitures(aptId)
    if self.properties.complex == "Apartment" then
        return Apartments[self.identifier]:GetFurnitures(aptId)
    else
        return self.properties.furniture
    end
end

---Delete House furnitures
---@param area? boolean
function Home:DeleteFurnitures(area)
    local furnitures = self:GetFurnitures()
    if furnitures then
        for k, v in pairs(furnitures) do
            if (area and area == v.area) or (not area and not v.area) then
                if v.identifier then
                    if Config.target then
                        RemoveTargetZone("storage:" .. self.identifier .. ":" .. v.identifier)
                    else
                        if self.zones.storages[v.identifier] then
                            self.zones.storages[v.identifier]:remove()
                            self.zones.storages[v.identifier] = nil
                        end
                    end
                    if Config.EnableMarkers.enable then
                        if self.points.storages and self.points.storages[v.identifier] then
                            self.points.storages[v.identifier]:remove()
                        end
                    end
                end
            end
        end
    end
    if area then
        for i = 1, #self.areaObjects do
            local obj = self.areaObjects[i].object
            debugPrint(obj)
            RemoveTargetEntity(obj, { "Open Storage" })
            DeleteEntity(obj)
        end
        self.areaObjects = {}
    else
        for i = 1, #self.spawnedObjects do
            local obj = self.spawnedObjects[i].object
            debugPrint(obj)
            RemoveTargetEntity(obj, { "Open Storage" })
            DeleteEntity(obj)
        end
        self.spawnedObjects = {}
    end
    TriggerEvent("Housing:client:DeleteFurnitures", self, furnitures, area)
    -- Experimental qb-weed
    TriggerEvent("qb-weed:client:leaveHouse")
end

function Home:GetFurnituresByType(furnitureType)
    local furnitures = {}
    if self.properties.complex == "Apartment" then
        furnitures = Apartments[self.identifier]:GetFurnitures()
    else
        furnitures = self.properties.furniture
    end
    local list = {}
    for i = 1, #furnitures do
        if FurnitureModelList[furnitures[i].model].type and FurnitureModelList[furnitures[i].model].type == furnitureType then
            list[#list + 1] = furnitures[i]
        end
    end
    return list
end

function Home:UpdateFurniture(furnitures, aptId)
    for i = 1, #furnitures do
        furnitures[i].key = i
    end
    if self.properties.complex == 'Apartment' and (aptId or LocalPlayer.state.CurrentApartment) then
        Apartments[self.identifier]:UpdateFurniture(furnitures, aptId)
    else
        self.properties.furniture = furnitures
    end
end

function Home:GetPlayersInside()
    return lib.callback.await('Housing:server:GetPlayersInside', false, self.identifier,
        LocalPlayer.state.CurrentApartment) or {}
end

function Home:GetEntryCoords()
    return self.properties.complex == 'Flat' and
        ToVector3(self.properties.data.flat.coords) or
        ToVector3(self.properties.entry)
end

local function EnterHomeValidation(homeType, interior)
    if homeType == 'shell' then
        if not IsModelValid(interior) then
            print('[HOUSING] ^1Shell does not exists! Make sure it is loaded', interior)
            return false
        elseif not Shells[interior] then
            print(('[HOUSING] ^1Shell %s is not in the list! Make sure it is config/shells.lua'):format(interior))
            return false
        end
    elseif homeType == 'mlo_teleport' then
        if not GetMloTeleport(interior) then
            print(('[HOUSING] ^1MLO Teleport %s does not exists!'):format(interior))
            return false
        end
    end
    return true
end

function Home:EnterHome(isVisiting, aptId, teleport)
    if not isVisiting then
        local allowed = lib.callback.await('Housing:server:EnterCheck', false, self.identifier, aptId, teleport)
        if not allowed then return end
    end

    if LocalPlayer.state.isInsideHome then
        return print(('[^3HOUSING^0] ^3 %s Trying to enter a home while already inside one'):format(GetInvokingResource()))
    end
    if self.properties.type == 'ipl' and type(self.properties.data.interior) == 'string' then
        local customizeIpl = GetCustomizeIPL(self.identifier, nil, isVisiting)

        if not customizeIpl then
            print('[HOUSING] ^1CustomizeIPL does not exists! Make sure it is loaded ', self.properties.data.interior)
            return
        end
    elseif self.properties.type ~= 'ipl' and not EnterHomeValidation(self.properties.type, self.properties.data.interior) then
        return
    end
    LocalPlayer.state:set('isInsideHome', true)
    TriggerServerEvent('Housing:server:Enter', self.identifier, aptId)
    TriggerServerEvent("Housing:server:UpdateLastProperty", self.identifier .. (aptId and ':' .. aptId or ''))
    if PlayerData and not (self:isKeyOwner(aptId) or self:isTenant()) and not isVisiting then
        TriggerServerEvent("Housing:server:AlertOwner", self.identifier, aptId)
    end
    CurrentHome = table.clone(self)
    CurrentHome.entry = self.properties.complex == "Flat" and self.properties.data.flat.coords or self.properties.entry
    if CurrentHome.properties.complex == 'Apartment' and not isVisiting then
        LocalPlayer.state:set('CurrentApartment', aptId)
    end
    LocalPlayer.state:set('CurrentHome', CurrentHome)
    debugPrint('[EnterHome] entering home, CurrentHome set', self.identifier)
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end
    local entry = {}
    if self.properties.type == "shell" then
        CurrentHome.object = CreateShell(self.properties.data.interior, self.properties.data.placement)
        if not CurrentHome.object then
            return
        end

        local heading = teleport?.w or Shells[self.properties.data.interior].w

        entry = GetOffsetFromEntityInWorldCoords(CurrentHome.object, Shells[self.properties.data.interior].x,
            Shells[self.properties.data.interior].y, Shells[self.properties.data.interior].z)
        ---@diagnostic disable-next-line
        SetEntityCoordsNoOffset(cache.ped, teleport and ToVector3(teleport) or entry)
        SetEntityHeading(CurrentHome.object, self.properties.data.placement.w)
        SetEntityHeading(cache.ped, heading)
        FreezeEntityPosition(cache.ped, true)
        Wait(2500)
    elseif self.properties.type == "ipl" then
        if type(self.properties.data.interior) == 'table' then
            entry = ToVector3(self.properties.data.interior.entry)
        elseif type(self.properties.data.interior) == 'string' then
            local customizeIpl = GetCustomizeIPL(self.identifier, nil, isVisiting)
            if customizeIpl then
                customizeIpl:Load(self.identifier, aptId)

                entry = customizeIpl.entry.xyz
                SetEntityCoordsNoOffset(cache.ped, teleport and ToVector3(teleport) or entry)
                SetEntityHeading(cache.ped, teleport?.w or customizeIpl.entry.w)
            end
        end
    elseif self.properties.type == "mlo_teleport" then
        local interior = GetMloTeleport(self.properties.data.interior)
        if interior then
            entry = interior.entry.xyz
            SetEntityCoordsNoOffset(cache.ped, teleport and ToVector3(teleport) or entry)
            SetEntityHeading(cache.ped, teleport?.w or tonumber(interior.entry.w) + 0.0)
        end
    end
    CurrentHome.entryInside = entry
    LocalPlayer.state:set('interiorEntrance', entry)
    FreezeEntityPosition(cache.ped, false)
    Wait(500)
    if self.properties.type == 'shell' then
        local timeOut = 0
        repeat
            SetEntityCoordsNoOffset(cache.ped, teleport and ToVector3(teleport) or entry)
            SetEntityHeading(cache.ped, teleport?.w or Shells[self.properties.data.interior].w)
            Wait(500)
            timeOut += 1
            if timeOut > 60 then
                print(('[HOUSING] ^1Failed to enter shell %s check coords in config/shells.lua!'):format(self
                    .properties.data.interior))
                self:ExitHome()
                break
            end
        until not IsPedFalling(cache.ped)
    end
    DoScreenFadeIn(500)
    inside = true
    self:CreateInsideEntrance(entry)

    if self.properties.type == 'shell' then
        ToggleSyncTime()
    end
    if not isVisiting then
        local data = lib.callback.await('Housing:server:GetData', false, self.identifier, aptId)
        -- Initialize furniture, storage and wardrobes
        self:SetData(data, aptId)
        self:SpawnFurnitures()
    end

    if self.properties.type ~= 'mlo' and self.properties.complex ~= 'Apartment' then
        self:InitDoors()
        self:SetTeleports()
    end

    TriggerEvent('Housing:client:OnEnterHome', self.identifier, aptId)
    TriggerServerEvent("Housing:addlog", "action",
        locale("log_player_enter_home"),
        locale("log_player_enter_home_msg", CurrentHome.properties.name, PlayerData.name, GetIdentifier()))
    CurrentHome.RadiusChecker = lib.points.new({
        coords = entry,
        distance = Config.RadiusShellCheck,
        onExit = function()
            SetEntityCoordsNoOffset(cache.ped, entry)
        end
    })

    if Config.Bill.enabled then
        LoadBill(self.identifier, aptId)
    end

    return true
end

function Home:ExitHome(teleport)
    self:DeleteWardrobesZone()

    if self.properties.type ~= 'mlo' then
        self:DeleteDoors()
    end

    self:DeleteFurnitures()
    self:DeleteStoragesZone()
    if CurrentHome.RadiusChecker then
        CurrentHome.RadiusChecker:remove()
    end
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end
    if Config.Bill.enabled then
        UnloadBill(self.identifier, LocalPlayer.state.CurrentApartment)
    end
    SetEntityCoords(cache.ped, ToVector3(teleport) or ToVector3(CurrentHome.entry))
    SetEntityHeading(cache.ped, teleport?.w or CurrentHome.entry.w - 180.0)
    if Config.AutoLock and Homes[CurrentHome.identifier] and not exports[GetCurrentResourceName()]:isLocked(self.identifier) and (Homes[CurrentHome.identifier]:isKeyOwner() or Homes[CurrentHome.identifier]:isTenant() or isPolice()) and #self:GetPlayersInside() <= 1 then
        TriggerServerEvent('Housing:server:LockHome', CurrentHome.identifier, false, LocalPlayer.state.CurrentApartment,
            true)
    end
    DeleteEntity(CurrentHome.object)
    Wait(500)

    if CurrentHome.HouseEntrance then CurrentHome.HouseEntrance:remove() end
    if Config.target then RemoveTargetZone("HouseEntrance-" .. self.identifier) end
    TriggerServerEvent("Housing:server:UpdateLastProperty", "outside")
    TriggerServerEvent("Housing:addlog", "action", locale("log_player_left_home"),
        locale("log_player_left_home_msg", self.properties.name, PlayerData.name,
            GetIdentifier()))
    debugPrint('[EnterHome] leaving home, CurrentHome emptied')
    if self.properties.complex == 'Apartment' then
        LocalPlayer.state:set('CurrentApartment', nil)
    end
    CurrentHome = {}
    LocalPlayer.state:set('interiorEntrance', nil)
    LocalPlayer.state:set('CurrentHome', {})
    LocalPlayer.state:set('isInsideHome', false)
    TriggerEvent('Housing:client:OnExitHome', self.identifier)
    TriggerServerEvent('Housing:server:Exit', self.identifier)
    inside = false
    Wait(500)
    DoScreenFadeIn(500)

    if self.properties.complex ~= 'Apartment' then
        self:SetTeleports()
    end

    if self.properties.type ~= 'mlo' then
        if self.properties.area and self.zones.areaZone then
            if self.zones.areaZone.insideZone then
                self.zones.areaZone.insideZone = false
            end
        end
    end
end
