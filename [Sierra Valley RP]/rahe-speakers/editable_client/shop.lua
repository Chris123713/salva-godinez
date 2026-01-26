local shopPoint
local shopInnerPoint
local shopBlip
local openShopKeybind

CreateThread(function()
    if shConfig.useTargeting then
        return
    end

    openShopKeybind = lib.addKeybind({
        name = 'speaker-open-shop',
        description = locale('Open speaker shop'),
        defaultKey = shConfig.shopDefaultKey,
        onPressed = function(self)
            if lib.getOpenContextMenu() then
                return
            end

            TriggerServerEvent('rahe-speakers:server:openSpeakerShop')
        end,
        disabled = true,
    })
end)


local function createShopTarget(entityId)
    if targetResource == 'ox_target' then
        exports.ox_target:addLocalEntity({entityId}, {
            {
                label = locale('Speaker shop'),
                icon = 'fa-solid fa-basket-shopping',
                name = 'r-speaker-shop',
                distance = 2.0,
                onSelect = function()
                    TriggerServerEvent('rahe-speakers:server:openSpeakerShop')
                end,
            },
        })
    elseif targetResource == 'qb-target' then
        exports['qb-target']:AddTargetEntity(entityId, {
            options = {
                {
                    label = locale('Speaker shop'),
                    icon = 'fa-solid fa-basket-shopping',
                    num = 1,
                    action = function()
                        TriggerServerEvent('rahe-speakers:server:openSpeakerShop')
                    end,
                },
            },
            distance = 2.0,
        })
    end
end

local function removeShopTarget(entityId)
    if targetResource == 'ox_target' then
        exports.ox_target:removeLocalEntity({entityId}, {'r-speaker-shop'})
    elseif targetResource == 'qb-target' then
        exports['qb-target']:RemoveTargetEntity(entityId, {locale('Speaker shop')})
    end
end

AddEventHandler('rahe-speakers:client:createShop', function(coords, model, blip)
    local shopCoords = vector3(coords.x, coords.y, coords.z)

    shopPoint = lib.points.new(shopCoords, 60.0, {
        model = model,
        heading = coords.w,
    })

    function shopPoint:onEnter()
        lib.requestModel(self.model, 2000)

        self.handle = CreatePed(0, model, self.coords.x, self.coords.y, self.coords.z, self.heading, false, true)

        SetModelAsNoLongerNeeded(self.model)
        FreezeEntityPosition(self.handle, true)
		SetEntityInvincible(self.handle, true)
		SetBlockingOfNonTemporaryEvents(self.handle, true)
        
        if shConfig.useTargeting then
            createShopTarget(self.handle)
        end
    end

    function shopPoint:onExit()
        if shConfig.useTargeting then
            removeShopTarget(self.handle)
        end

        if DoesEntityExist(self.handle) then
            SetEntityAsMissionEntity(self.handle, false, true)
            DeleteEntity(self.handle)
        end

        self.handle = nil
    end

    if not shConfig.useTargeting then
        shopInnerPoint = lib.points.new(shopCoords, 1.5)

        function shopInnerPoint:onEnter()
            showTextUI(locale('[%s] Speaker shop', openShopKeybind.currentKey), {
                icon = 'music',
                position = clConfig.interactionUiPosition,
            })
            openShopKeybind:disable(false)
        end

        function shopInnerPoint:onExit()
            hideTextUI()
            openShopKeybind:disable(true)
        end
    end

    if not blip then
        return
    end

    shopBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(shopBlip, blip.sprite)
    SetBlipColour(shopBlip, blip.color)
    SetBlipScale(shopBlip, blip.scale or 1.0)
    SetBlipAsShortRange(shopBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(blip.text)
    EndTextCommandSetBlipName(shopBlip)
end)

RegisterNetEvent('rahe-speakers:client:openSpeakerShop', function(speakerTypes, maxRange, maxVolume)
    local options = {}

    for k, v in pairs(speakerTypes) do
        local rangeProgress = math.floor((v.maxRange / maxRange) * 100)
        local volumeProgress = math.floor((v.maxVolume / maxVolume) * 100)

        table.insert(options, {
            title = ('%s ($%.2f)'):format(v.label, v.price),
            description = v.description,
            icon = v.image,
            image = v.image,
            args = v.id,
            arrow = true,
            price = v.price,
            progress = rangeProgress,
            colorScheme = 'teal',
            metadata = {
                {label = locale('Range'), value = ('%s/%s'):format(v.maxRange, maxRange), progress = rangeProgress},
                {label = locale('Max volume'), value = ('%s/%s'):format(v.maxVolume, maxVolume), progress = volumeProgress},
            },
            onSelect = function()
                local message = locale('Are sure you want to purchase %s for $%.2f?', v.label, v.price)

                local confirmation = lib.alertDialog({
                    header = locale('Confirmation'),
                    content = message,
                    centered = true,
                    cancel = true
                })
                
                if confirmation ~= 'confirm' then
                    return
                end

                TriggerServerEvent('rahe-speakers:server:purchaseSpeaker', v.id)
            end,
        })
    end

    lib.registerContext({
        id = 'speaker-shop',
        title = locale('Speaker shop'),
        options = options,
    })

    lib.showContext('speaker-shop')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    if shopBlip then
        RemoveBlip(shopBlip)
    end

    if not shopPoint then
        return
    end

    if shopPoint.handle and DoesEntityExist(shopPoint.handle) then
        removeShopTarget(shopPoint.handle)
        SetEntityAsMissionEntity(shopPoint.handle, false, true)
        DeleteEntity(shopPoint.handle)
    end
end)