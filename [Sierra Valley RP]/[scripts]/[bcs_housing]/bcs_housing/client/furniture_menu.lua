local furnitureItem, menu, furnitureItemCoords
local ownedFurnitures = {}
local isShop = false

RegisterNUICallback('hideFrame', function(data, cb)
    if (furnitureItem) then
        DeleteEntity(furnitureItem)
        furnitureItem = nil
    end
    furnitureItemCoords = nil
    menu = nil
    if ownedFurnitures and next(ownedFurnitures) then
        ownedFurnitures = {}
    end
    isShop = false
    cb({})
end)

function SpawnPreviewFurniture(data)
    if furnitureItem and DoesEntityExist(furnitureItem) then
        furnitureItemCoords = GetEntityCoords(furnitureItem)
        DeleteEntity(furnitureItem)
    end

    if BusyspinnerIsOn() then
        return
    elseif not IsModelValid(data.model) then
        return print(('[Housing]^1 Model ^3%s ^1is not mounted / streamed'):format(data.model))
    end

    if lib.requestModel(data.model) then
        local isShop = Config.EnableFurnitureShop and menu == 'furniture_shop'
        local coords = isShop and GetClosestFurnitureSpawn()
            or furnitureItemCoords

        if not isShop and not furnitureItemCoords then
            local fwv = GetEntityForwardVector(cache.ped)
            coords = GetEntityCoords(cache.ped) + fwv * 2.0
        end

        furnitureItem = CreateObject(GetHashKey(data.model), coords, false, true)
        PlaceObjectOnGroundProperly(furnitureItem)
        UpdateGizmoEntity(furnitureItem)
        lastSelected = {
            entity = furnitureItem,
            data = data
        }
        FreezeEntityPosition(furnitureItem, true)
        StartEntityGizmo(furnitureItem, 'furniture_shop')
        CurrentMode = 'gizmo'
        SetModelAsNoLongerNeeded(data.model)
        if isShop then
            SetCameraEntity(furnitureItem)
        end
    end
end

function SpawnCopyGizmo()
    if lastSelected then
        local data = lastSelected.data
        if lib.requestModel(data.model) then
            local coords = GetEntityCoords(lastSelected.entity)
            furnitureItem = CreateObject(GetHashKey(data.model), coords.x, coords.y, coords.z, false, true, false)
            SetModelAsNoLongerNeeded(data.model)
            PlaceObjectOnGroundProperly(furnitureItem)
            UpdateGizmoEntity(furnitureItem)
            lastSelected = {
                entity = furnitureItem,
                data = data
            }
            FreezeEntityPosition(furnitureItem, true)
            StartEntityGizmo(furnitureItem, 'furniture_shop')
        end
    end
end

RegisterNUICallback('selectFurnitureShop', function(data, cb)
    if (data) then
        -- if menu == 'furnish' and ownedFurnitures and next(ownedFurnitures) then
        --     PlaceFurniture(data)
        --     SendReactMessage('setPage', 'editfurniture/shop')
        -- else
        SpawnPreviewFurniture(data)
        -- end
    end
    cb({})
end)

RegisterNUICallback('checkCategories', function(data, cb)
    local list = {}
    if menu == 'furnish' and ownedFurnitures and next(ownedFurnitures) and Config.EnableFurnitureShop then
        for i = 1, #ownedFurnitures do
            if ownedFurnitures[i].isometric == data then
                table.insert(list, ownedFurnitures[i].category)
            end
        end
    elseif FurnitureList[data] and (menu ~= 'furnish' or not Config.EnableFurnitureShop) then
        for k, v in pairs(FurnitureList[data]) do
            table.insert(list, k)
        end
    end
    cb(list)
end)

RegisterNUICallback('getCategories', function(data, cb)
    local categories = {}
    if (GlobalState.FurnitureCategories[data]) then
        for k, v in pairs(GlobalState.FurnitureCategories[data]) do
            if menu == 'furnish' and ownedFurnitures and next(ownedFurnitures) and Config.EnableFurnitureShop then
                for i = 1, #ownedFurnitures do
                    if k == ownedFurnitures[i].category then
                        table.insert(categories, { val = k, label = v })
                    end
                end
            elseif not FurnitureList[data][k].hidden or (menu == 'furnish' or not Config.EnableFurnitureShop) then
                table.insert(categories, { val = k, label = v })
            end
        end
    end
    cb(categories)
end)

RegisterNUICallback('getFurnitureCategories', function(_, cb)
    if menu == 'furnish' and Config.EnableFurnitureShop then
        local categories = {}
        if Config.FurnitureAsItem then
            local itemFurnitures = GetFurnitureItems()
            if itemFurnitures then
                for i = 1, #itemFurnitures do
                    if not TableContainsValue(categories, GetCategoryByModel(itemFurnitures[i].model)) then
                        table.insert(categories, GetCategoryByModel(itemFurnitures[i].model))
                    end
                end
            end
        elseif ownedFurnitures then
            for i = 1, #ownedFurnitures do
                if not TableContainsValue(categories, ownedFurnitures[i].category) then
                    table.insert(categories, ownedFurnitures[i].category)
                end
            end
        end
        return cb(categories)
    elseif isInFurnitureShop() or not Config.EnableFurnitureShop then
        cb(FurnitureCategories)
    end
end)

RegisterNUICallback('getFurnitureCategoryList', function(data, cb)
    local list = {}

    local function AddToList(furniture)
        furniture.image = GlobalState.FurnitureImages[tostring(GetHashKey(furniture.model))]
        if furniture.slots or furniture.weight then
            furniture.type = 'storage'
        end
        table.insert(list, furniture)
    end

    if menu == 'furnish' and Config.EnableFurnitureShop then
        if Config.FurnitureAsItem then
            local itemFurnitures = GetFurnitureItems()
            if itemFurnitures then
                for i = 1, #itemFurnitures do
                    if GetCategoryByModel(itemFurnitures[i].model):lower() == data:lower() then
                        local furnitureData = FindFurniture(itemFurnitures[i].label, FurnitureModelList)
                        if furnitureData then
                            AddToList(furnitureData)
                        end
                    end
                end
            end
        elseif ownedFurnitures then
            for i = 1, #ownedFurnitures do
                if ownedFurnitures[i].category:lower() == data:lower() then
                    AddToList(ownedFurnitures[i])
                end
            end
        end
    elseif isInFurnitureShop() or not Config.EnableFurnitureShop then
        for i = 1, #FullList[data].list do
            local furniture = FullList[data].list[i]
            furniture.image = GlobalState.FurnitureImages[tostring(joaat(furniture.model))]
            if furniture.slots or furniture.weight then
                furniture.type = 'storage'
            end
            table.insert(list, furniture)
        end
    end
    cb(list)
end)

RegisterNUICallback('setFurnitureMenu', function(data, cb)
    menu = data
    cb({})
end)

RegisterNUICallback('buyFurniture', function(data, cb)
    if LocalPlayer.state.designInterior then
        StopGizmo()
        lastSelected = {}
        SetNuiFocusKeepInput(true)

        if furnitureItem then
            local coords = GetEntityCoords(furnitureItem)
            local heading = GetEntityHeading(furnitureItem)
            local rotation = GetEntityRotation(furnitureItem)
            TriggerEvent("Housing:client:BuyFurniture", data, coords, heading, rotation)
            Wait(1)
            DeleteEntity(furnitureItem)
            furnitureItem = nil
        end
        furnitureItemCoords = nil
        return cb(true)
    end
    if Config.EnableFurnitureShop then
        lib.callback("Housing:server:BuyFurniture", false, function(result)
            if result then
                lib.callback("Housing:server:GetOwnedFurnitures", false, function(furnitures)
                    ownedFurnitures = furnitures
                end)
            end
        end, data)
    else
        StopGizmo()
        local canPlace = ConfirmPlacement(furnitureItem, data)
        lastSelected = {}
        SetNuiFocusKeepInput(true)
        if furnitureItem then
            DeleteEntity(furnitureItem)
            furnitureItem = nil
        end
        furnitureItemCoords = nil
    end
    cb({})
end)

RegisterNUICallback('sellFurniture', function(data, cb)
    local success = lib.callback.await('Housing:server:SellFurniture', false, data.item)
    if success then
        lib.callback("Housing:server:GetOwnedFurnitures", false, function(furnitures)
            ownedFurnitures = furnitures
        end)
    end
    cb(success)
end)

function OpenFurnitureMenu(mode)
    if Config.FurnitureMenu == 'ox_lib' then
        if Config.EnableFurnitureShop and mode == 'furniture_shop' then
            lib.showMenu('furniture_shop')
        else
            if Config.EnableFurnitureShop then
                lib.setMenuOptions('furniture_menu',
                    { label = 'Inventory', description = 'Check & Sell your furnitures' }, 2)
            end
            lib.showMenu('furniture_menu')
        end
    else
        lib.callback("Housing:server:GetOwnedFurnitures", false, function(furnitures)
            ownedFurnitures = furnitures
            ToggleNuiFrame(true)
            menu = mode
            isShop = true
            SetNuiFocusKeepInput(true)
            CreateThread(function()
                while isShop do
                    local FORCEABLE <const> = {
                        1,  -- Look Left/Right
                        2,  -- Look up/Down
                        30, -- Player Movement
                        31, -- Player Movement
                        22, -- Jump
                        23  -- Enter vehicle
                    }
                    DisableAllControlActions(0)
                    CamGizmoControl()
                    if IsDisabledControlPressed(0, 25) and (CurrentMode ~= 'gizmo') then
                        for i = 1, #FORCEABLE do
                            EnableControlAction(0, FORCEABLE[i], true)
                        end
                    end
                    Wait(0)
                end
            end)
            SendReactMessage('setPage', 'furnitureshop/' .. mode .. '?shop=' .. tostring(Config.EnableFurnitureShop))
        end)
    end
end

function isInFurnitureShop()
    return isShop
end

AddEventHandler("Housing:client:EditFurniture", function() isShop = true end)

function FindFurniture(label, list)
    local temp = list or FurnitureModelList
    for model, v in pairs(temp) do
        if v.label == label then
            return v
        end
    end
end

CreateThread(function()
    while not next(FullList) do
        Wait(200)
    end

    Wait(2000)

    local optionList = {
        { label = 'Back' }
    }
    for category, v in pairs(FullList) do
        optionList[#optionList + 1] = {
            label = v.label,
            values = v.list,
            close = false,
        }
    end

    lib.registerMenu({
        id = 'furniture_shop',
        title = locale('furniture_shop'),
        position = 'top-right',
        onSideScroll = function(selected, scrollIndex, args)
            local data = FindFurniture(optionList[selected].values[scrollIndex].label)
            if (data) then
                if menu == 'furnish' and ownedFurnitures and next(ownedFurnitures) and not isShop then
                    PlaceFurniture(data)
                else
                    if furnitureItem then DeleteEntity(furnitureItem) end

                    if BusyspinnerIsOn() then
                        return
                    end

                    if lib.requestModel(data.model) then
                        local coords = GetClosestFurnitureSpawn()

                        if not Config.EnableFurnitureShop then
                            local fwv = GetEntityForwardVector(cache.ped)
                            coords = GetEntityCoords(cache.ped) + fwv * 2.0
                        end

                        furnitureItem = CreateObject(GetHashKey(data.model), coords, false, true)
                        FreezeEntityPosition(furnitureItem, true)
                        SetModelAsNoLongerNeeded(data.model)
                    end
                end
            end
        end,
        onClose = function(keyPressed)
            if (furnitureItem) then
                DeleteEntity(furnitureItem)
                furnitureItem = nil
            end
            menu = nil
            if ownedFurnitures and next(ownedFurnitures) then
                ownedFurnitures = {}
            end
            isShop = false
            StopCameraEntity()
        end,
        options = optionList
    }, function(selected, scrollIndex, args)
        if selected == 1 then
            lib.hideMenu(true)
            Wait(500)
            lib.showMenu('furniture_menu')
        else
            -- buy
            if Config.EnableFurnitureShop then
                local data = FindFurniture(optionList[selected].values[scrollIndex].label)
                lib.callback("Housing:server:BuyFurniture", false, function(result)
                    if result then

                    end
                end, data)
            else
                lib.hideMenu(true)

                local data = FindFurniture(optionList[selected].values[scrollIndex].label)
                if furnitureItem then DeleteEntity(furnitureItem) end
                StopGizmo()
                PlaceFurniture(data)
                SendReactMessage('setPage', 'editfurniture/shop')
            end
        end
    end)

    local function OpenFurnitureInventory()
        lib.hideMenu(true)
        ownedFurnitures = lib.callback.await('Housing:server:GetOwnedFurnitures', false)
        local options = {
            { label = 'Back' }
        }
        for i = 1, #ownedFurnitures do
            options[#options + 1] = { label = ownedFurnitures[i].label, close = false }
        end
        lib.registerMenu({
            id = 'furniture_inventory',
            title = locale('furniture_inventory'),
            position = 'top-right',
            options = options
        }, function(selected, scrollIndex, args)
            if selected == 1 then
                lib.hideMenu(true)
                lib.showMenu('furniture_menu')
            else
                -- sell
                local data = FindFurniture(options[selected].label)
                local success = lib.callback.await('Housing:server:SellFurniture', false, data)
                if success then
                    OpenFurnitureInventory()
                end
            end
        end)
        lib.showMenu('furniture_inventory')
    end

    local function FurnishHouseMenu()
        lib.hideMenu(true)
        ownedFurnitures = lib.callback.await('Housing:server:GetOwnedFurnitures', false)
        local options = {
            { label = locale('back') }
        }

        for i = 1, #ownedFurnitures do
            options[#options + 1] = { label = ownedFurnitures[i].label, close = false }
        end

        lib.registerMenu({
            id = 'furnish_house_menu',
            title = 'Furnish House',
            position = 'top-right',
            options = options
        }, function(selected, scrollIndex, args)
            if selected == 1 then
                lib.hideMenu(true)
                lib.showMenu('furniture_menu')
            else
                lib.hideMenu(true)

                local data = FindFurniture(options[selected].label)
                StopGizmo()
                PlaceFurniture(data)
                SendReactMessage('setPage', 'editfurniture/shop')
            end
        end)
        lib.showMenu('furnish_house_menu')
    end

    lib.registerMenu({
        id = 'furniture_menu',
        title = locale('furniture_menu'),
        position = 'top-right',
        options = {
            {
                label = Config.EnableFurnitureShop and locale('furnish_home') or locale('furniture_shop'),
                description = Config.EnableFurnitureShop and locale('furnish_home_body') or locale('furniture_shop_desc')
            },
        }
    }, function(selected, scrollIndex, args)
        if selected == 1 then
            if Config.EnableFurnitureShop then
                FurnishHouseMenu()
            else
                lib.showMenu('furniture_shop')
                displayHelp(locale('prompt_furnitureshop'), 'bottom-right')
                menu = 'furniture_shop'
                isShop = true
                while isInFurnitureShop() do
                    DisableControlAction(0, 82, true)
                    DisableControlAction(0, 81, true)
                    DisableControlAction(0, 244, true)

                    if furnitureItem then
                        if IsDisabledControlPressed(0, 81) then
                            SetEntityHeading(furnitureItem, GetEntityHeading(furnitureItem) + 1.0)
                        elseif IsDisabledControlPressed(0, 82) then
                            SetEntityHeading(furnitureItem, GetEntityHeading(furnitureItem) - 1.0)
                        end
                    end

                    Wait(0)
                end
                closeHelp()
            end
        elseif selected == 2 then
            OpenFurnitureInventory()
        end
    end)
end)

function GetCategoryByModel(model)
    return FurnitureModelList[model].category
end

function RemoveOwnedFurniture(furniture)
    if ownedFurnitures then
        for k, v in pairs(ownedFurnitures) do
            if v.model == furniture.model then
                if v.identifier then
                    if v.identifier == furniture.identifier then
                        table.remove(ownedFurnitures, k)
                        break
                    end
                else
                    table.remove(ownedFurnitures, k)
                    break
                end
            end
        end
    end

    if furniture then
        SendReactMessage(('refreshFurnitureList%s'):format(GetCategoryByModel(furniture.model)), {})
    end
end

CreateThread(function()
    lib.callback('Housing:server:GetFurniture', false, function(paths)
        debugPrint("^4[INFO] ^7[Furniture] ^4 Loading furniture from paths: \n", table.concat(paths, ", \n"))

        for i = 1, #paths do
            debugPrint("^4[INFO] ^7[Furniture] ^4 Loading furniture from path: " .. paths[i])

            local success, furnitures = pcall(require, paths[i])

            if success and furnitures then
                debugPrint(("^2[SUCCESS] ^7[Furniture] ^2Loaded furniture: %s with %d items"):format(furnitures.label,
                    #furnitures.list))

                table.insert(FurnitureList, furnitures)

                if furnitures.list and not furnitures.hidden then
                    for j = 1, #furnitures.list, 1 do
                        furnitures.list[j].category = furnitures.label
                        FurnitureModelList[furnitures.list[j].model] = furnitures.list[j]

                        if not FullList[furnitures.label] then
                            FullList[furnitures.label] = {
                                label = furnitures.label,
                                list = {}
                            }
                            table.insert(FurnitureCategories, furnitures.label)
                        end

                        furnitures.list[j].description = 'Price $' .. furnitures.list[j].price
                        table.insert(FullList[furnitures.label].list, furnitures.list[j])
                    end
                end
            else
                debugPrint(("^3[WARNING] ^7[Furniture] ^3 Failed to load furniture from path: %s"):format(paths[i]))
            end
        end
        loadingFurnitures = false
    end)
end)

exports('GetFurnitureList', function()
    return FullList
end)
