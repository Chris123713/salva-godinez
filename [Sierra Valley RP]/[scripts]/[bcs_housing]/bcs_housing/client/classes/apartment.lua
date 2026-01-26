Apartment = {}

Apartment.__index = Apartment

Apartment.__newindex = function(self, name, fn)
    rawset(self, name, fn)
end

function Apartment:new(home)
    local self = setmetatable({}, Apartment)
    self.zones = {}
    self.points = {}
    self.apartments = home.apartments
    for i = 1, #self.apartments do
        self.apartments[i].keys = Keys:new(
            home.identifier,
            self.apartments[i].keys.list and ConvertToTable(self.apartments[i].keys.list) or {},
            self.apartments[i].keys.holders and ConvertToTable(self.apartments[i].keys.holders) or {},
            self.apartments[i].apartment
        )
    end
    self.name = home.name
    self.identifier = home.identifier
    self:SetEntranceZone(home.entry, home.name)
    return self
end

function Apartment:AddApartment(aptId, owner)
    local data = lib.callback.await("Housing:server:GetData", false, self.identifier, aptId)
    self.apartments[#self.apartments + 1] = {
        locked = false,
        apartment = aptId,
        owner = owner,
        storages = data and data.storages or {},
        wardrobes = data and data.wardrobes or {},
        furniture = data and data.furniture or {},
        plan = data and data.plan or {},
        keys = Keys:new(self.identifier, {}, {}, aptId)
    }
    if self.apartments[#self.apartments].storages and next(self.apartments[#self.apartments].storages) then
        local list = {}
        for k, v in pairs(self.apartments[#self.apartments].storages) do
            list[#list + 1] = v
        end
        self.apartments[#self.apartments].storages = list
    end
end

function Apartment:RemoveApartment(aptId)
    for i = 1, #self.apartments do
        if self.apartments[i].apartment == aptId then
            table.remove(self.apartments, i)
            break
        end
    end
end

function Apartment:Refresh(home)
    self.apartments = home.apartments
end

function Apartment:GetOwnedApartmentId(identifier)
    for i = 1, #self.apartments do
        if self.apartments[i].owner == (identifier or GetIdentifier()) then
            return self.apartments[i].apartment
        end
    end
end

function Apartment:GetApartmentById(aptId)
    for i = 1, #self.apartments do
        if self.apartments[i].apartment == tonumber(aptId) then
            return self.apartments[i]
        end
    end
end

function Apartment:OwnApartment(identifier)
    local have = self:GetOwnedApartmentId(identifier)
    return have and true or false
end

function Apartment:Entrance(home)
    lib.callback('Housing:server:OwnApartment', false, function(owned)
        CreateThread(function()
            local boxes = {}
            HelpText(true, locale('prompt_apartment_menu'))
            if owned then
                boxes = {}
                if not home.disabled then
                    table.insert(boxes, {
                        text = {
                            title = locale('lock_home'),
                            body = locale('lock_home_body')
                        },
                        icon = "lock",
                        server = true,
                        event = "Housing:server:LockHome",
                        args = { home.identifier, false, self:GetOwnedApartmentId() }
                    })
                end
            else
                boxes = {}
                if not home.disabled then
                    table.insert(boxes, {
                        text = {
                            title = locale('preview_home')
                        },
                        icon = 'eye',
                        event = "Housing:client:EnterHome",
                        args = { home.identifier, true }
                    })
                end
                if not home.disabled and not home.configuration.disableBuy then
                    table.insert(boxes, {
                        text = {
                            title = home.properties.payment == 'Rent' and locale('rent_apartment') or
                                locale('buy_apartment')
                        },
                        icon = 'receipt',
                        event = "Housing:client:BuyHome",
                        args = { home.identifier }
                    })
                end
            end
            if not home.disabled then
                table.insert(boxes, {
                    text = {
                        title = locale('list_rooms')
                    },
                    icon = 'home',
                    event = 'Housing:client:ApartmentListRoom',
                    args = { home.identifier }
                })
            end
            while inZone do
                Wait(2)
                if IsControlJustReleased(0, 38) then
                    HelpText(false)
                    if not home.disabled and (self:GetOwnedApartmentId() and not self:GetApartmentById(self:GetOwnedApartmentId()).locked) then
                        table.insert(boxes, {
                            text = {
                                title = locale('enter_home')
                            },
                            icon = 'eye',
                            event = "Housing:client:EnterHome",
                            args = { home.identifier, false, self:GetOwnedApartmentId() }
                        })
                    end
                    TriggerEvent("Housing:client:CreateMenu", {
                        title = home.properties.name,
                        subtitle = locale('apartment_menu'),
                        boxes = boxes
                    })
                    break
                end
            end
            while IsNuiFocused() do
                Wait(1000)
            end
            Wait(200)
            if inZone then
                self:Entrance(home)
            end
        end)
    end, home.identifier)
end

RegisterNetEvent('Housing:client:ApartmentEntrance', function(homeId, aptId)
    local home = Apartments[homeId]
    local apt = home:GetApartmentById(aptId)
    local boxes = {}
    if apt.locked then
        if Config.robbery.enable then
            table.insert(boxes, {
                text = {
                    title = locale('lockpick_home'),
                    body = locale('lockpick_home_body'),
                },
                icon = 'lock',
                event = "Housing:client:StartLockpick",
                args = { home.identifier, aptId }
            })
        end
        if apt.keys:HasKey(GetIdentifier(), nil, aptId) then
            table.insert(boxes, {
                text = {
                    title = locale('unlock_home'),
                },
                icon = 'lock',
                server = true,
                event = "Housing:server:LockHome",
                args = { home.identifier, false, aptId }
            })
        end
        table.insert(boxes, {
            text = {
                title = locale('knock_door'),
            },
            icon = 'lock',
            server = true,
            event = "Housing:server:KnockDoor",
            args = { home.identifier, aptId }
        })
        if Config.robbery.enableRaid and isPolice() then
            table.insert(boxes, {
                text = {
                    title = locale('raid_home'),
                    body = locale('raid_home_body')
                },
                icon = 'grab',
                event = "Housing:client:RaidDoor",
                args = { home.identifier, aptId }
            })
        end
    else
        table.insert(boxes, {
            text = {
                title = locale('enter_home'),
            },
            icon = 'door-open',
            event = "Housing:client:EnterHome",
            args = { home.identifier, false, aptId }
        })
    end

    TriggerEvent("Housing:client:CreateMenu", {
        title = home.name,
        subtitle = locale('apartment_menu'),
        boxes = boxes
    })
end)

RegisterNetEvent('Housing:client:ApartmentListRoom', function(homeId)
    local apt = Apartments[homeId]
    local list = {}
    local nameData = lib.callback.await('Housing:server:GetNames', false, true)
    for i = 1, #apt.apartments do
        if apt.apartments[i].owner ~= GetIdentifier() then
            table.insert(list, {
                text = {
                    title = locale('apt_title', nameData.apartments
                        [apt.identifier .. ':' .. apt.apartments[i].apartment])
                },
                icon = 'eye',
                event = "Housing:client:ApartmentEntrance",
                args = { apt.identifier, apt.apartments[i].apartment }
            })
        end
    end
    TriggerEvent("Housing:client:CreateMenu", {
        title = apt.name,
        subtitle = locale('list_rooms'),
        boxes = list
    })
end)

function Apartment:isLocked(aptId)
    local apartment = self:GetApartmentById(aptId or LocalPlayer.state.CurrentApartment)
    return apartment and apartment.locked or false
end

function Apartment:SetEntranceZone(entry, label)
    local homeId = self.identifier
    if Config.target then
        AddTargetBoxZone('entrance-' .. label, {
            coords = ToVector3(entry),
            length = 2.0,
            width = 2.0,
            heading = entry.w,
            debugPoly = Config.debug,
            minZ = entry.z - 1.0,
            maxZ = entry.z + 2.0
        }, {
            options = {
                {
                    label = locale('buy_apartment'),
                    icon = 'fa-solid fa-receipt',
                    action = function()
                        TriggerEvent("Housing:client:BuyHome", self.identifier)
                    end,
                    canInteract = function()
                        return not self:OwnApartment() and not Homes[self.identifier].disabled and
                            not Homes[self.identifier].configuration.disableBuy
                    end,
                },
                {
                    icon = "fas fa-door-open",
                    label = locale('list_rooms'),
                    canInteract = function()
                        return not Homes[self.identifier].disabled
                    end,
                    action = function()
                        TriggerEvent("Housing:client:ApartmentListRoom", self.identifier)
                    end
                },
                {
                    icon = "fas fa-door-open",
                    label = locale('enter_home'),
                    action = function()
                        TriggerEvent('Housing:client:EnterHome', self.identifier, false, self:GetOwnedApartmentId())
                    end,
                    canInteract = function()
                        return self:OwnApartment() and not self:GetApartmentById(self:GetOwnedApartmentId()).locked and
                            not Homes[self.identifier].disabled
                    end
                },
                {
                    icon = "fas fa-door-open",
                    label = locale('lock_home'),
                    action = function()
                        TriggerServerEvent('Housing:server:LockHome', self.identifier, nil, self:GetOwnedApartmentId())
                    end,
                    canInteract = function()
                        return self:OwnApartment() and not self:GetApartmentById(self:GetOwnedApartmentId()).locked and
                            not Homes[self.identifier].disabled
                    end
                },
                {
                    icon = "fas fa-door-open",
                    label = locale('unlock_home'),
                    action = function()
                        TriggerServerEvent('Housing:server:LockHome', self.identifier, nil, self:GetOwnedApartmentId())
                    end,
                    canInteract = function()
                        return self:OwnApartment() and self:GetApartmentById(self:GetOwnedApartmentId()).locked,
                            not Homes[self.identifier].disabled
                    end
                },
                {
                    icon = "fas fa-eye",
                    label = locale('preview_home'),
                    action = function()
                        TriggerEvent('Housing:client:EnterHome', self.identifier, true)
                    end,
                    canInteract = function()
                        return not self:OwnApartment() and not Homes[self.identifier].disabled
                    end
                }
            },
            distance = 3.5
        })
    else
        self.zones.entranceZone = lib.zones.box({
            name = 'entrance-' .. label,
            coords = ToVector3(entry),
            size = vec3(1.5, 1.5, 2.5),
            rotation = entry.w,
            debug = Config.debug,
            onEnter = function()
                inZone = true
                self:Entrance(Homes[homeId])
            end,
            onExit = ExitZone
        })
    end
    if Config.EnableMarkers.enable then
        self.points.entrance = lib.points.new({
            coords = ToVector3(entry),
            distance = 3,
            nearby = function()
                DrawMarker(Config.EnableMarkers.type, ToVector3(entry), 0.0, 0.0, 0.0, 0,
                    0.0, 0.0, Config.EnableMarkers.size.x, Config.EnableMarkers.size.y,
                    Config.EnableMarkers.size.z, Config.EnableMarkers.color.r,
                    Config.EnableMarkers.color.g, Config.EnableMarkers.color.b, 100, false, true, 2,
                    false, false, false, false)
            end
        })
    end
end

function Apartment:DestroyZone(name)
    if self.zones.entranceZone then
        self.zones.entranceZone:remove()
    elseif Config.target then
        RemoveTargetZone('entrance-' .. name)
    end
    if self.points.entrance then
        self.points.entrance:remove()
    end
end

function Apartment:GetStorages()
    local aptId = LocalPlayer.state.CurrentApartment or self:GetOwnedApartmentId()
    if aptId then
        local apartment = self:GetApartmentById(aptId)
        return apartment.storages
    end
end

function Apartment:MoveStorage(id, coords, area)
    local aptId = LocalPlayer.state.CurrentApartment or self:GetOwnedApartmentId()
    if aptId then
        local apartment = self:GetApartmentById(aptId)
        if not apartment.storages then
            apartment.storages = {}
        end
        for i = 1, #apartment.storages do
            if apartment.storages[i].id == id then
                apartment.storages[i].coords = coords
                apartment.storages[i].area = area
                return apartment.storages[i]
            end
        end
    end
end

function Apartment:CreateStorage(data, id)
    local aptId = id or LocalPlayer.state.CurrentApartment
    if aptId then
        local apartment = self:GetApartmentById(aptId)
        if not apartment.storages then
            apartment.storages = {}
        end
        apartment.storages[#apartment.storages + 1] = data
    end
end

function Apartment:DeleteStorage(id, aptId)
    for i = 1, #self.apartments do
        if self.apartments[i].apartment == aptId and self.apartments[i].storages then
            for j = 1, #self.apartments[i].storages do
                if self.apartments[i].storages[j].id == id then
                    table.remove(self.apartments[i].storages, j)
                    TriggerServerEvent('Housing:server:UpdateStorage', { homeId = self.identifier, aptId = aptId },
                        { id = id }, true)
                    break
                end
            end
        end
    end
end

function Apartment:GetWardrobes()
    local aptId = LocalPlayer.state.CurrentApartment
    if aptId then
        local apartment = self:GetApartmentById(aptId)
        return apartment and apartment.wardrobes or false
    end
end

function Apartment:AddWardrobe(wardrobe, aptId)
    if aptId then
        local apartment = self:GetApartmentById(aptId)
        if not apartment.wardrobes then
            apartment.wardrobes = {}
        end
        apartment.wardrobes[#apartment.wardrobes + 1] = wardrobe
    end
end

function Apartment:RemoveWardrobe(name, aptId)
    if aptId then
        local apartment = self:GetApartmentById(aptId)
        if not apartment.wardrobes then
            apartment.wardrobes = {}
        end
        for i = 1, #apartment.wardrobes do
            if apartment.wardrobes[i].name == name then
                table.remove(apartment.wardrobes, i)
            end
        end
    end
end

function Apartment:GetFurnitures(id)
    local aptId = id or LocalPlayer.state.CurrentApartment
    if aptId then
        local apartment = self:GetApartmentById(aptId)
        return apartment and apartment.furniture or false
    end
end

function Apartment:UpdateFurniture(furnitures, id)
    local aptId = id or LocalPlayer.state.CurrentApartment
    if aptId then
        local apartment = self:GetApartmentById(aptId)
        if apartment then
            apartment.furniture = furnitures
        end
    end
end
