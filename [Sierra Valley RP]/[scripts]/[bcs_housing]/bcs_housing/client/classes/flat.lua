Flat = {}

Flat.__index = Flat

Flat.__newindex = function(self, name, fn)
    rawset(self, name, fn)
end

RegisterNetEvent('Housing:client:FlatEntrance', function(data)
    Wait(200)
    if data.properties.owner then
        debugPrint('[flatEntrance]', 'Entrance of owned house ' .. data.properties.owner)
        lib.callback('Housing:server:isOwner', false, function(isOwner)
            debugPrint('[flatEntrance]', 'Lock condition', data.properties.locked)
            local boxes = {}
            if not data.properties.locked then
                table.insert(boxes, {
                    text = {
                        title = locale('enter_home')
                    },
                    icon = 'door-open',
                    event = "Housing:client:EnterHome",
                    args = { data.identifier }
                })
            end
            if isOwner or isAgent(data.properties.realestate, 'unlock') then
                table.insert(boxes, {
                    text = {
                        title = locale('lock_home'),
                        body = locale('lock_home_body'),
                    },
                    icon = 'lock',
                    server = true,
                    event = "Housing:server:LockHome",
                    args = { data.identifier }
                })
                if isOwner and Homes[data.identifier].permission.sell then
                    table.insert(boxes, {
                        text = {
                            title = locale('sell_home'),
                            body = locale('sell_home_body'),
                        },
                        event = "Housing:client:SellHome",
                        icon = 'receipt',
                        args = { data.identifier }
                    })
                end
            else
                if not isOwner and data.properties.owner and data.properties.rent and data.properties.rent.isRented then
                    table.insert(boxes, {
                        text = {
                            title = locale('rent_home')
                        },
                        icon = 'receipt',
                        event = "Housing:client:RentMenu",
                        args = { data.identifier }
                    })
                end
                if Config.robbery.enable then
                    table.insert(boxes, {
                        text = {
                            title = locale('lockpick_home'),
                            body = locale('lockpick_home_body'),
                        },
                        icon = 'unlock',
                        event = "Housing:client:StartLockpick",
                        args = { data.identifier }
                    })
                end
                table.insert(boxes, {
                    text = {
                        title = locale('knock_door'),
                    },
                    icon = 'unlock',
                    server = true,
                    event = "Housing:server:KnockDoor",
                    args = { data.identifier }
                })
                if Config.robbery.enableRaid and isPolice() then
                    table.insert(boxes, {
                        text = {
                            title = locale('raid_home'),
                            body = locale('raid_home_body')
                        },
                        icon = 'grab',
                        event = "Housing:client:RaidDoor",
                        args = { data.identifier }
                    })
                end
            end
            TriggerEvent("Housing:client:CreateMenu", {
                title = data.properties.name,
                subtitle = locale('house_entrance_menu'),
                boxes = boxes,
            })
        end, data.identifier)
    else
        local boxes = {}
        if not data.disabled then
            table.insert(boxes, {
                text = {
                    title = locale('preview_home')
                },
                icon = 'eye',
                event = "Housing:client:EnterHome",
                args = { data.identifier, true }
            })
        end
        if not data.configuration.disableBuy then
            table.insert(boxes, {
                text = {
                    title = data.properties.payment == 'Rent' and locale('rent_home') or locale('buy_home')
                },
                icon = 'receipt',
                event = "Housing:client:BuyHome",
                args = { data.identifier }
            })
        end
        TriggerEvent("Housing:client:CreateMenu", {
            title = data.properties.name,
            subtitle = locale('house_menu'),
            boxes = boxes
        })
    end
end)

RegisterNetEvent('Housing:client:FlatOwnedEntrance', function(data)
    local boxes = {}
    for _, room in pairs(data.rooms) do
        if room.properties.owner == (GetIdentifier()) then
            table.insert(boxes, {
                text = {
                    title = room.properties.name
                },
                icon = 'door-open',
                event = 'Housing:client:FlatEntrance',
                args = { room }
            })
        end
    end
    TriggerEvent("Housing:client:CreateMenu", {
        title = data.name,
        subtitle = locale('owned_flat_entrance_menu'),
        boxes = boxes,
    })
end)

function Flat:Entrance()
    CreateThread(function()
        HelpText(true, locale('prompt_flat_menu'))
        local boxes = {}
        table.insert(boxes, {
            text = {
                title = locale('owned_flat_filter')
            },
            icon = 'door-open',
            event = 'Housing:client:FlatOwnedEntrance',
            args = { self }
        })
        for _, room in pairs(self.rooms) do
            table.insert(boxes, {
                text = {
                    title = room.properties.name
                },
                icon = 'door-open',
                event = 'Housing:client:FlatEntrance',
                args = { room }
            })
        end
        while inZone do
            Wait(2)
            if IsControlJustReleased(0, 38) then
                HelpText(false)
                TriggerEvent("Housing:client:CreateMenu", {
                    title = self.name,
                    subtitle = locale('flat_entrance_menu'),
                    boxes = boxes,
                })
                break
            end
        end
        while IsNuiFocused() do
            Wait(1000)
        end
        Wait(200)
        if inZone then
            self:Entrance()
        end
    end)
end

function Flat:OpenFlatMenu()
    local boxes = {}
    table.insert(boxes, {
        text = {
            title = locale('owned_flat_filter')
        },
        icon = 'door-open',
        event = 'Housing:client:FlatOwnedEntrance',
        args = { self }
    })
    for _, room in pairs(self.rooms) do
        table.insert(boxes, {
            text = {
                title = room.properties.name
            },
            icon = 'door-open',
            event = 'Housing:client:FlatEntrance',
            args = { room }
        })
    end
    TriggerEvent("Housing:client:CreateMenu", {
        title = self.name,
        subtitle = locale('flat_entrance_menu'),
        boxes = boxes,
    })
end

function Flat:DestroyZone()
    if self.zones.entranceZone then
        self.zones.entranceZone:remove()
    elseif Config.target then
        RemoveTargetZone('entrance-flat-' .. self.name)
    end
    if Config.EnableMarkers.enable and self.points.entrance then
        self.points.entrance:remove()
    end
end

function Flat:SetEntranceZone(room)
    local entry = room.properties.data.flat.coords
    if Config.target then
        AddTargetBoxZone('entrance-flat-' .. self.name, {
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
                    label = locale('open_flat_menu'),
                    icon = 'fa-solid fa-door-open',
                    action = function()
                        self:OpenFlatMenu()
                    end,
                },
            },
            distance = 3.5
        })
    else
        self.zones.entranceZone = lib.zones.box({
            coords = ToVector3(entry),
            size = vec3(1.5, 1.5, 2.5),
            rotation = entry.w,
            debug = Config.debug,
            onEnter = function()
                inZone = true
                if room.properties.type == 'shell' or room.properties.type == 'ipl' then
                    self:Entrance()
                end
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

function Flat:new(room)
    local self = setmetatable({}, Flat)
    local entry = room.properties.data.flat.coords
    self.rooms = {}
    self.zones = {}
    self.points = {}
    self.entry = entry
    self.name = room.properties.data.flat.name

    self:SetEntranceZone(room)

    self:AddRoom(room)
    return self
end

function Flat:AddRoom(room)
    self.rooms[#self.rooms + 1] = room
end
