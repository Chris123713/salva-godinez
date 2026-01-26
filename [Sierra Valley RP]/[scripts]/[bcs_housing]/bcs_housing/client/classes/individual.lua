local DEFAULT_ZONE_SIZE = vec3(1.5, 1.5, 2.5)

Individual = {}

Individual.__index = Individual

Individual.__newindex = function(self, name, fn)
    rawset(self, name, fn)
end

function Individual:new(home)
    local self = setmetatable({}, Individual)
    self.zones = {}
    self.points = {}
    self.identifier = home.identifier
    self:SetEntranceZone(home.properties.entry, home.properties.name)
    return self
end

function Individual:Entrance(home)
    CreateThread(function()
        if home.properties.owner then
            debugPrint('[Individual:Entrance]', 'Entrance of owned house ' .. home.properties.owner)
            lib.callback('Housing:server:isOwner', false, function(isOwner)
                debugPrint('[Individual:Entrance]', 'Lock condition', home.properties.locked)
                local boxes = {}
                if not home.properties.locked then
                    HelpText(true, locale('prompt_enter_home'))
                    table.insert(boxes, {
                        text = {
                            title = locale('enter_home')
                        },
                        icon = 'door-open',
                        event = "Housing:client:EnterHome",
                        args = { home.identifier }
                    })
                end
                if isOwner or isAgent(home.properties.realestate, 'unlock') then
                    table.insert(boxes, {
                        text = {
                            title = locale('lock_home'),
                            body = locale('lock_home_body'),
                        },
                        icon = 'lock',
                        server = true,
                        event = "Housing:server:LockHome",
                        args = { home.identifier }
                    })
                    if isOwner and home.permission.sell then
                        table.insert(boxes, {
                            text = {
                                title = locale('sell_home'),
                                body = locale('sell_home_body'),
                            },
                            event = "Housing:client:SellHome",
                            icon = 'banknote',
                            args = { home.identifier }
                        })
                    end
                end
                if not isOwner and home.properties.owner and home.properties.rent and home.properties.rent.isRented then
                    table.insert(boxes, {
                        text = {
                            title = locale('rent_home')
                        },
                        icon = 'receipt',
                        event = "Housing:client:RentMenu",
                        args = { home.identifier }
                    })
                end
                if home.properties.locked and isOwner then
                    HelpText(true, locale('prompt_unlock_door'))
                elseif home.properties.locked then
                    HelpText(true, locale('prompt_enter_home'))
                    if Config.robbery.enable then
                        table.insert(boxes, {
                            text = {
                                title = locale('lockpick_home'),
                                body = locale('lockpick_home_body'),
                            },
                            icon = 'lock',
                            event = "Housing:client:StartLockpick",
                            args = { home.identifier }
                        })
                    end
                    table.insert(boxes, {
                        text = {
                            title = locale('knock_door'),
                        },
                        icon = 'lock',
                        server = true,
                        event = "Housing:server:KnockDoor",
                        args = { home.identifier }
                    })
                    if Config.robbery.enableRaid and isPolice() then
                        table.insert(boxes, {
                            text = {
                                title = locale('raid_home'),
                                body = locale('raid_home_body')
                            },
                            icon = 'grab',
                            event = "Housing:client:RaidDoor",
                            args = { home.identifier }
                        })
                    end
                end
                if boxes and #boxes > 0 then
                    while inZone do
                        Wait(2)
                        if IsControlJustReleased(0, 38) then
                            HelpText(false)
                            if home.properties.locked and (isOwner or isAgent(home.properties.realestate, 'unlock')) then
                                TriggerServerEvent('Housing:server:LockHome', home.identifier)
                            else
                                TriggerEvent("Housing:client:CreateMenu", {
                                    title = home.properties.name,
                                    subtitle = locale('house_entrance_menu'),
                                    boxes = boxes,
                                })
                            end
                            break
                        end
                    end
                    while IsNuiFocused() or busy do
                        Wait(1000)
                    end
                    Wait(200)
                    if inZone then
                        local updatedData = Homes[home.identifier]
                        self:Entrance(updatedData)
                    end
                end
            end, home.identifier)
        else
            -- If home is not owned then else buy prompt
            HelpText(true, locale('prompt_buy_home'))
            while inZone do
                Wait(2)
                if IsControlJustReleased(0, 38) then
                    HelpText(false)
                    local boxes = {}
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
                                title = home.properties.payment == 'Rent' and locale('rent_home') or
                                    locale('buy_home')
                            },
                            icon = 'receipt',
                            event = "Housing:client:BuyHome",
                            args = { home.identifier }
                        })
                    end
                    TriggerEvent("Housing:client:CreateMenu", {
                        title = home.properties.name,
                        subtitle = locale('house_menu'),
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
                self:Entrance(Homes[home.identifier])
            end
        end
    end)
end

function Individual:MLOEntrance(home)
    CreateThread(function()
        if not home.properties.owner then
            HelpText(true, locale('prompt_buy_home'))
            while inZone do
                Wait(2)
                if IsControlJustReleased(0, 38) then
                    HelpText(false)
                    if not home.disabled and not home.configuration.disableBuy then
                        TriggerEvent("Housing:client:CreateMenu", {
                            title = home.properties.name,
                            subtitle = locale('house_menu'),
                            boxes = {
                                {
                                    text = {
                                        title = home.properties.payment == 'Rent' and locale('rent_home') or
                                            locale('buy_home')
                                    },
                                    icon = 'receipt',
                                    event = "Housing:client:BuyHome",
                                    args = { home.identifier }
                                }
                            }
                        })
                    else
                        Notify(locale('housing'), 'This house cannot be bought!', 'error', 3000)
                    end
                    break
                end
            end
        elseif home.properties.owner then
            local isOwner = home:isOwner()
            if not isOwner and not (home.properties.rent and home.properties.rent.isRented) then
                return
            end
            HelpText(true, locale('prompt_home_menu'))
            while inZone do
                Wait(2)
                if IsControlJustReleased(0, 38) then
                    HelpText(false)
                    local isOwner = home:isOwner()
                    local boxes = {}
                    if isOwner and home.permission.sell then
                        table.insert(boxes, {
                            text = {
                                title = locale('sell_home'),
                                body = locale('sell_home_body'),
                            },
                            event = "Housing:client:SellHome",
                            icon = 'banknote',
                            args = { home.identifier }
                        })
                    end
                    if not home:isKeyOwner() and home.properties.rent and home.properties.rent.isRented then
                        table.insert(boxes, {
                            text = {
                                title = locale('rent_home')
                            },
                            icon = 'receipt',
                            event = "Housing:client:RentMenu",
                            args = { home.identifier }
                        })
                    end
                    TriggerEvent("Housing:client:CreateMenu", {
                        title = home.properties.name,
                        subtitle = locale('house_menu'),
                        boxes = boxes
                    })
                    break
                end
            end
        end
    end)
end

function Individual:DestroyZone(name)
    if self.zones.entranceZone then
        self.zones.entranceZone:remove()
    elseif Config.target then
        RemoveTargetZone('entrance-' .. name)
    end
    if Config.EnableMarkers.enable and self.points.entrance then
        self.points.entrance:remove()
    end
end

function Individual:SetEntranceZone(entry, label)
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
                    label = locale('buy_home'),
                    icon = 'fa-solid fa-receipt',
                    action = function()
                        TriggerEvent("Housing:client:BuyHome", homeId)
                    end,
                    canInteract = function()
                        return not Homes[homeId].disabled and not Homes[homeId].properties.owner and
                            not Homes[homeId].configuration.disableBuy
                    end,
                },
                {
                    label = locale('rent_home'),
                    icon = 'fa-solid fa-receipt',
                    action = function()
                        TriggerEvent("Housing:client:RentMenu", homeId)
                    end,
                    canInteract = function()
                        return not Homes[homeId].disabled and Homes[homeId].properties.rent and
                            Homes[homeId].properties.rent.isRented and
                            Homes[homeId].properties.owner and
                            not Homes[homeId]:isKeyOwner() and not Homes[homeId]:isTenant() and
                            not Homes[homeId].properties.rent.tenant
                    end,
                },
                {
                    label = locale('lockpick_home'),
                    icon = 'fa-solid fa-lock',
                    action = function()
                        TriggerEvent("Housing:client:StartLockpick", homeId)
                    end,
                    canInteract = function()
                        return not Homes[homeId].disabled and Config.robbery.enable and Homes[homeId].properties.locked and
                            not Homes[homeId]:isKeyOwner() and
                            not Homes[homeId]:isTenant() and
                            Homes[homeId].properties.type ~= 'mlo'
                    end
                },
                {
                    label = locale('knock_door'),
                    icon = 'fa-solid fa-lock',
                    action = function()
                        TriggerServerEvent("Housing:server:KnockDoor", homeId)
                    end,
                    canInteract = function()
                        return not Homes[homeId].disabled and Homes[homeId].properties.locked and
                            not Homes[homeId]:isKeyOwner() and
                            not Homes[homeId]:isTenant() and
                            Homes[homeId].properties.type ~= 'mlo'
                    end
                },
                {
                    label = locale('raid_home'),
                    icon = 'fa-solid fa-hand-fist',
                    action = function()
                        TriggerEvent("Housing:client:RaidDoor", homeId)
                    end,
                    canInteract = function()
                        return not Homes[homeId].disabled and Homes[homeId].properties.locked and
                            not Homes[homeId]:isKeyOwner() and
                            not Homes[homeId]:isTenant() and
                            Config.robbery.enableRaid and
                            isPolice() and Homes[homeId].properties.type ~= 'mlo'
                    end
                },
                {
                    icon = "fas fa-door-open",
                    label = locale('enter_home'),
                    action = function()
                        TriggerEvent('Housing:client:EnterHome', homeId)
                    end,
                    canInteract = function()
                        return not Homes[homeId].disabled and not Homes[homeId].properties.locked and
                            Homes[homeId].properties.type ~= 'mlo' and
                            Homes[homeId].properties.owner
                    end
                },
                {
                    icon = "fas fa-eye",
                    label = locale('preview_home'),
                    action = function()
                        TriggerEvent('Housing:client:EnterHome', homeId, true)
                    end,
                    canInteract = function()
                        return not Homes[homeId].disabled and not Homes[homeId].properties.owner and
                            Homes[homeId].properties.type ~= 'mlo'
                    end
                },
                {
                    label = locale('unlock_home'),
                    icon = "fa-solid fa-lock",
                    action = function()
                        TriggerServerEvent("Housing:server:LockHome", homeId)
                    end,
                    canInteract = function()
                        return not Homes[homeId].disabled and Homes[homeId].properties.locked and
                            (Homes[homeId]:isKeyOwner() or Homes[homeId]:isTenant() or isAgent(Homes[homeId].properties.realestate, 'unlock')) and
                            Homes[homeId].properties.type ~= 'mlo'
                    end
                },
                {
                    label = locale('lock_home'),
                    icon = "fa-solid fa-lock",
                    action = function()
                        TriggerServerEvent("Housing:server:LockHome", homeId)
                    end,
                    canInteract = function()
                        return not Homes[homeId].disabled and not Homes[homeId].properties.locked and
                            (Homes[homeId]:isKeyOwner() or Homes[homeId]:isTenant() or isAgent(Homes[homeId].properties.realestate, 'unlock')) and
                            Homes[homeId].properties.type ~= 'mlo'
                    end
                },
                {
                    label = locale('sell_home'),
                    icon = 'fa-solid fa-receipt',
                    action = function()
                        TriggerEvent('Housing:client:SellHome', homeId)
                    end,
                    canInteract = function()
                        return not Homes[homeId].disabled and Homes[homeId]:isOwner() and Homes[homeId].permission.sell
                    end
                }
            },
            distance = 3.5
        })
    else
        self.zones.entranceZone = lib.zones.box({
            name = 'entrance-' .. label,
            coords = ToVector3(entry),
            size = DEFAULT_ZONE_SIZE,
            rotation = entry.w,
            debug = Config.debug,
            onEnter = function()
                inZone = true
                if Homes[homeId].properties.type == 'shell' or Homes[homeId].properties.type == 'ipl' then
                    self:Entrance(Homes[homeId])
                elseif Homes[homeId].properties.type == 'mlo' then
                    self:MLOEntrance(Homes[homeId])
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
                if Homes[homeId] and (not Homes[homeId].properties.owner and Homes[homeId].properties.type == 'mlo') or Homes[homeId].properties.type ~= 'mlo' then
                    DrawMarker(Config.EnableMarkers.type, ToVector3(entry), 0.0, 0.0, 0.0, 0,
                        0.0, 0.0, Config.EnableMarkers.size.x, Config.EnableMarkers.size.y,
                        Config.EnableMarkers.size.z, Config.EnableMarkers.color.r,
                        Config.EnableMarkers.color.g, Config.EnableMarkers.color.b, 100, false, true, 2,
                        false, false, false, false)
                end
            end
        })
    end
end
