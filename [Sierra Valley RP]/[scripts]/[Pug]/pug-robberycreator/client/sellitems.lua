local AllSellItemsData
local SellItemsProp = {}
local CreatedTarget = {}

local function EndMultipleNetworkAnimation(stage, ObjectData)
    local ChosenAnimation
    if Config.RobberyAnimations[stage.animation] then
        ChosenAnimation = Config.RobberyAnimations[stage.animation]
    else
        ChosenAnimation = Config.Animations[tonumber(stage.animation)]
    end
    if ChosenAnimation.NetworkedAnimations then
        if #ChosenAnimation.NetworkedAnimations == 1 then
            if GetJewelryCases(stage.propName) then
            else
                if stage.propName == "tr_prop_tr_container_01a" then
                    Wait(4000)
                end
            end
            DestroyAllProps()
            if Config.RobberyAnimations[stage.animation] then
                if Config.RobberyAnimations[stage.animation].ReplaceProp then
                    if GetJewelryCases(stage.animation) then
                        ClearPedTasks(PlayerPedId()) 
                    end
                    if not GetJewelryCases(stage.animation) then
                        TriggerServerEvent("Pug:server:CreateSyncedProps",  ObjectData.Coords, ObjectData.Rotation, ChosenAnimation.NetworkedAnimations[1].AnimDict, ObjectData.RobberyName, stage.propName, ObjectData)
                    end
                else
                    ClearPedTasks(PlayerPedId()) 
                end
            end
            return
        end
        if ChosenAnimation.NetworkedAnimations[#ChosenAnimation.NetworkedAnimations] then
            if ChosenAnimation.NetworkedAnimations[2].AnimAction == "drill_straight_end_idle" and ChosenAnimation.NetworkedAnimations[2].AnimationOptions.SecondProp == "hei_prop_heist_drill" then
                StopSound(soundIdGolbal)
                ReleaseAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET")
                ReleaseAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL")
                ReleaseAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2")
            end
            DestroyAllProps()
            local i = #ChosenAnimation.NetworkedAnimations
            local k = tonumber(stage.animation)
            
            local ZOffset = ChosenAnimation.NetworkedAnimations[i].ZOffset
            local YOffset = ChosenAnimation.NetworkedAnimations[i].YOffset
            local XOffset = ChosenAnimation.NetworkedAnimations[i].XOffset
            loadAnimDict(ChosenAnimation.NetworkedAnimations[i].AnimDict)

            local PlayerCoords = GetEntityCoords(PlayerPedId())
            local PlayerHeading = GetEntityHeading(PlayerPedId())
        

            local radians = math.rad(PlayerHeading)
            local rotatedXOffset = XOffset * math.cos(radians) - YOffset * math.sin(radians)
            local rotatedYOffset = XOffset * math.sin(radians) + YOffset * math.cos(radians)
             
            local Location, Rotation = vector3(PlayerCoords.x + rotatedXOffset, PlayerCoords.y + rotatedYOffset, PlayerCoords.z + ZOffset), vector3(0.0, 0.0, PlayerHeading)
            if ObjectData then
                Location, Rotation = ObjectData.Coords, ObjectData.Rotation
                if Config.RobberyAnimations[stage.animation] then
                    if Config.RobberyAnimations[stage.animation].ReplaceProp then
                        TriggerServerEvent("Pug:server:CreateSyncedProps",  ObjectData.Coords, ObjectData.Rotation, ChosenAnimation.NetworkedAnimations[1].AnimDict, ObjectData.RobberyName, stage.propName, ObjectData)
                    end
                end
            end

            local NetworkScene = NetworkCreateSynchronisedScene(Location, Rotation, 2, true, false, 1065353216, 0, 1.3)
            NetworkAddPedToSynchronisedScene(PlayerPedId(), NetworkScene, ChosenAnimation.NetworkedAnimations[i].AnimDict, ChosenAnimation.NetworkedAnimations[i].AnimAction, 1.5, -4.0, 1, 1, 1148846080, 0)
            if ChosenAnimation.NetworkedAnimations[i].AnimationOptions then
				local PropName =  ChosenAnimation.NetworkedAnimations[i].AnimationOptions.Prop
				local SecondPropEmote
				PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack({0, 0, 0, 0, 0})
				if ChosenAnimation.NetworkedAnimations[i].AnimationOptions.SecondProp then
					SecondPropName = ChosenAnimation.NetworkedAnimations[i].AnimationOptions.SecondProp
					SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6 = table.unpack({0, 0, 0, 0, 0})
					SecondPropEmote = true
				end
				AddPropToPlayer(PropName, PropBone, PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6, PlayerPedId(), true)
				while not DoesEntityExist(prop) do Wait(100) end
				NetworkAddEntityToSynchronisedScene(prop, NetworkScene, ChosenAnimation.NetworkedAnimations[i].AnimationOptions.PropAnimationDict, ChosenAnimation.NetworkedAnimations[i].AnimationOptions.PropAnimation, 4.0, -8.0, 1)
				if SecondPropEmote then
					AddPropToPlayer(SecondPropName, SecondPropBone, SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6, PlayerPedId(), true)
					while not DoesEntityExist(prop) do Wait(100) end
					NetworkAddEntityToSynchronisedScene(prop, NetworkScene, ChosenAnimation.NetworkedAnimations[i].AnimationOptions.SecondPropAnimationDict, ChosenAnimation.NetworkedAnimations[i].AnimationOptions.SecondPropAnimation, 4.0, -8.0, 1)
				end
                if ChosenAnimation.NetworkedAnimations[i].AnimationOptions.ThirdProp then
					ThirdPropPl1, ThirdPropPl2, ThirdPropPl3, ThirdPropPl4, ThirdPropPl5, ThirdPropPl6 = table.unpack({0, 0, 0, 0, 0})
					AddPropToPlayer(ChosenAnimation.NetworkedAnimations[i].AnimationOptions.ThirdProp, ThirdPropPl1, ThirdPropPl2, ThirdPropPl3, ThirdPropPl4, ThirdPropPl5, ThirdPropPl6, PlayerPedId(), true)
					while not DoesEntityExist(prop) do Wait(100) end
					NetworkAddEntityToSynchronisedScene(prop, NetworkScene, ChosenAnimation.NetworkedAnimations[i].AnimationOptions.ThirdPropAnimationDict, ChosenAnimation.NetworkedAnimations[i].AnimationOptions.ThirdPropAnimation, 4.0, -8.0, 1)
				end
			end
            
            NetworkStartSynchronisedScene(NetworkScene)
            Wait(ChosenAnimation.NetworkedAnimations[i].WaitTime)
            DestoryCamera()
            DestroyAllProps()
            ClearPedTasks(PlayerPedId())
        end
    else
        ClearPedTasks(PlayerPedId())
    end
end

RegisterNUICallback('SaveSellLocationData', function(data, cb)
    TriggerServerEvent('Pug:saveSellItemsData', data)
    cb('ok')
end)

local function RemoveSellItemsTarget()
    for k, _ in pairs(SellItemsProp) do
        if DoesEntityExist(SellItemsProp[k]) then
            DeleteEntity(SellItemsProp[k])
        end
    end
    if Config.Target == 'ox_target' then
        for k, _ in pairs(CreatedTarget) do
            exports.ox_target:removeZone(k)
        end
    else
        for k, _ in pairs(CreatedTarget) do
            exports[Config.Target]:RemoveZone(k)
        end
    end
end

local SellingItems = false
local PendingRewards = {}

function CreateSellItemsTarget()
    for _, sellTargetData in ipairs(AllSellItemsData.targets) do
        local propName = sellTargetData.propName
        local propHeading = tonumber(sellTargetData.propHeading) or 0.0
        local targetVectorString = sellTargetData.targetVector
        local vectorParts = {}

        for part in string.gmatch(targetVectorString, "[^,]+") do
            table.insert(vectorParts, tonumber(part))
        end
        local propCoords = vector3(vectorParts[1], vectorParts[2], vectorParts[3])

        local PedCoords = sellTargetData.pedCoords
        local PedParts = {}

        for part in string.gmatch(PedCoords, "[^,]+") do
            table.insert(PedParts, tonumber(part))
        end
        local PedCoordsFinal = vector3(PedParts[1], PedParts[2], PedParts[3])

        local targetName = 'sellItemsTarget_' .. tostring(propCoords[1])
        if propName and propName ~= "" then
            LoadModel(propName)
            SellItemsProp[targetName] = CreateObject(GetHashKey(propName), propCoords.x, propCoords.y, propCoords.z, true, true, false)
            SetEntityHeading(SellItemsProp[targetName], propHeading)
            FreezeEntityPosition(SellItemsProp[targetName], true)
        end

        CreatedTarget[targetName]  = true
        
        -- Define options per item
        local options = {}
        if #sellTargetData.sellItems > 0 then
            for _, item in ipairs(sellTargetData.sellItems) do
                local itemName = item.itemName
                local itemData = item  -- local copy
                local itemLabel = 'Sell ' .. itemName
                if sellTargetData.targetText and sellTargetData.targetText ~= "" and sellTargetData.targetText ~= " " then
                    itemLabel = sellTargetData.targetText
                end
                if GetResourceState("RevoInteract") == 'started' or not Config.Target or Config.DrawTextInsteadOfTarget then
                    CreateThread(function()
                        local helpShown = false
                    
                        while CreatedTarget[targetName] do
                            local playerPed = PlayerPedId()
                            local playerCoords = GetEntityCoords(playerPed)
                            local distance = #(playerCoords - propCoords)
                            
                            if distance <= 1.5 then
                                if not helpShown then
                                    local formattedTargetName = targetName:gsub("[%s%.]+", "")
                                    -- print("SHOW", options)
                                    if GetResourceState("RevoInteract") == 'started' then
                                        exports.RevoInteract:OpenHelp({
                                            ID = formattedTargetName, 
                                            Text = itemLabel, 
                                            Key = "[E]" 
                                        })
                                    else
                                        DrawTextOption("[E] "..itemLabel)
                                    end
                                    helpShown = true
                                end
                                
                                if IsControlJustPressed(0, 38) then
                                    if not SellingItems then
                                        SellingItems = true
                                        local Continue = true
                                        local requiredQuantity = tonumber(itemData.quantity) or 0
                                        local playerItemCount = GetPlayerItemCount(itemData.itemName)
                                        local sellQuantity = 0
        
                                        if sellTargetData.sellAllItems then
                                            if playerItemCount < requiredQuantity then
                                                Notify("You do not have enough items to sell.", "error")
                                                SellingItems = false
                                                Continue = false
                                            end
                                            sellQuantity = playerItemCount
                                        else
                                            sellQuantity = requiredQuantity
                                            if playerItemCount < sellQuantity then
                                                Notify("You do not have enough items to sell.", "error")
                                                SellingItems = false
                                                Continue = false
                                            end
                                        end
                                        if Continue then
                                            if sellQuantity <= 0 then
                                                Notify("Invalid quantity to sell.", "error")
                                                SellingItems = false
                                                Continue = false
                                            end
                                            if Continue then
                                                -- Remove the item from player
                                                TriggerServerEvent("Pug:server:SellItems:Trade", tostring(itemData.itemName))
                
                                                SetEntityCoords(PlayerPedId(), PedCoordsFinal)
                                                local PlayerHeadingHere = tonumber(sellTargetData.playerHeading)
                                                if PlayerHeadingHere then
                                                    SetEntityHeading(PlayerPedId(), PlayerHeadingHere)
                                                end
                                                
                                                -- Play animation (if any)
                                                local animationType = sellTargetData.animation
                                                local ObjectData
                                                local stage = {
                                                    animation  = animationType,
                                                    propName = propName,
                                                }
                                                local ChosenAnimation
                                                if animationType and animationType ~= "" then
                                                    ChosenAnimation = Config.Animations[tonumber(animationType)] or Config.RobberyAnimations[animationType]
                                                    if ChosenAnimation then
                                                        local PropModel = propName
                                                        if type(PropModel) == "string" then
                                                            PropModel = GetHashKey(propName)
                                                        end
                                                        local Dist = 1.5
                                                        local sceneObject = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), Dist, PropModel, 0, 0, 0)
                                                        if sceneObject ~= 0 then
                                                            ObjectData = {
                                                                Coords = GetEntityCoords(sceneObject),
                                                                Rotation = GetEntityRotation(sceneObject),
                                                                PropName = propName,
                                                                Heist = "sellitems", -- Update for sell items
                                                                Stage = {},
                                                                DataObject = sceneObject,
                                                                Heading = GetEntityHeading(sceneObject),
                                                            }
                                                        end
                                                        if not ChosenAnimation.ReplaceProp then
                                                            TriggerEvent("Pug:client:DoRobberiesAnimation", animationType, PlayerPedId(), false, ObjectData, true)
                                                            Wait(5000)
                                                        end
                                                    end
                                                end
                
                                                CreateThread(function()
                                                    if ChosenAnimation then
                                                        if ChosenAnimation.AnimDict then
                                                            if ChosenAnimation.AnimAction then
                                                                local startTime = GetGameTimer()
                                                                while GetGameTimer() - startTime < 7000 do
                                                                    if not IsEntityPlayingAnim(PlayerPedId(), ChosenAnimation.AnimDict, ChosenAnimation.AnimAction, 3) then
                                                                        TriggerEvent("Pug:client:DoRobberiesAnimation", animationType, PlayerPedId(), false, ObjectData, true)
                                                                    end
                                                                    Wait(1000) -- Check every 1 second
                                                                end
                                                            end
                                                        end
                                                    end
                                                end)
                
                                                if sellTargetData.sendAlert then
                                                    if math.random(1, 100) <= 30 then
                                                        SendSuspiciousActivityCallToPolice()
                                                    end
                                                end
                
                                                FreezeEntityPosition(PlayerPedId(), true)
                                                Wait(7000)
                                                FreezeEntityPosition(PlayerPedId(), false)
                                                SellingItems = false
                
                                                -- Handle delay reward per item
                                                if itemData.delayReward and itemData.rewardDelayTime and tonumber(itemData.rewardDelayTime) > 0 then
                                                    local delayTimeInSeconds = tonumber(itemData.rewardDelayTime)
                
                                                    Notify(Config.LangT["WaitBeforeClaimingTrade"] .. itemData.rewardDelayTime .. " seconds before claiming your trade.", "error")
                                                    EndMultipleNetworkAnimation(stage, ObjectData)
                
                                                    -- -- Add to pending rewards
                                                    -- local pendingReward = {
                                                    --     itemData = itemData,
                                                    --     propCoords = propCoords,
                                                    --     propName = propName,
                                                    --     readyTime = GetGameTimer() + delayTimeInSeconds * 1000,
                                                    --     sellQuantity = sellQuantity,
                                                    -- }
                                                    -- table.insert(PendingRewards, pendingReward)
                                                    -- WaitForReadyTrade()
                                                    TriggerServerEvent("Pug:server:SellItems:Trade", tostring(itemData.itemName))
                                                else
                                                    -- Give reward immediately
                                                    local pendingReward = {
                                                        sellQuantity = sellQuantity,
                                                    }
                                                    -- GiveItemReward(itemData, pendingReward)
                                                    TriggerServerEvent("Pug:server:SellItems:Trade", tostring(itemData.itemName))
                                                    EndMultipleNetworkAnimation(stage, ObjectData)
                                                end
                                            end
                                        end
                                    else
                                        Notify(Config.LangT["AlreadySellingItem"], "error")
                                    end
                                    Wait(500)
                                end
                    
                                Wait(0)
                            else
                                local formattedTargetName = targetName:gsub("[%s%.]+", "")
                                if helpShown then
                                    -- print("HIDE", formattedTargetName)
                                    if GetResourceState("RevoInteract") == 'started' then
                                        exports.RevoInteract:CloseHelp(formattedTargetName)
                                    else
                                        HideTextOption()
                                    end
                                    helpShown = false
                                end
                                Wait(1000)
                            end
                        end
                    end)
                else
                    if Config.Target == "ox_target" then
                        table.insert(options, {
                            name = 'StartSellItem_' .. itemName,
                            icon = 'fas fa-box',
                            label = itemLabel,
                            distance = 1.5,
                            onSelect = function()
                                if not SellingItems then
                                    SellingItems = true
                                    local requiredQuantity = tonumber(itemData.quantity) or 0
                                    local playerItemCount = GetPlayerItemCount(itemData.itemName)
                                    local sellQuantity = 0

                                    if sellTargetData.sellAllItems then
                                        if playerItemCount < requiredQuantity then
                                            Notify("You do not have enough items to sell.", "error")
                                            SellingItems = false
                                            return
                                        end
                                        sellQuantity = playerItemCount
                                    else
                                        sellQuantity = requiredQuantity
                                        if playerItemCount < sellQuantity then
                                            Notify("You do not have enough items to sell.", "error")
                                            SellingItems = false
                                            return
                                        end
                                    end

                                    if sellQuantity <= 0 then
                                        Notify("Invalid quantity to sell.", "error")
                                        SellingItems = false
                                        return
                                    end

                                    -- Remove the item from player
                                    TriggerServerEvent("Pug:server:SellItems:Trade", tostring(itemData.itemName))

                                    SetEntityCoords(PlayerPedId(), PedCoordsFinal)
                                    local TargetLook = tonumber(sellTargetData.playerHeading)
                                    if TargetLook then
                                        SetEntityHeading(PlayerPedId(), TargetLook)
                                    end

                                    -- Play animation (if any)
                                    local animationType = sellTargetData.animation
                                    local ObjectData
                                    local stage = {
                                        animation  = animationType,
                                        propName = propName,
                                    }
                                    local ChosenAnimation
                                    if animationType and animationType ~= "" then
                                        ChosenAnimation = Config.Animations[tonumber(animationType)] or Config.RobberyAnimations[animationType]
                                        if ChosenAnimation then
                                            local PropModel = propName
                                            if type(PropModel) == "string" then
                                                PropModel = GetHashKey(propName)
                                            end
                                            local Dist = 1.5
                                            local sceneObject = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), Dist, PropModel, 0, 0, 0)
                                            if sceneObject ~= 0 then
                                                ObjectData = {
                                                    Coords = GetEntityCoords(sceneObject),
                                                    Rotation = GetEntityRotation(sceneObject),
                                                    PropName = propName,
                                                    Heist = "sellitems", -- Update for sell items
                                                    Stage = {},
                                                    DataObject = sceneObject,
                                                    Heading = GetEntityHeading(sceneObject),
                                                }
                                            end
                                            if not ChosenAnimation.ReplaceProp then
                                                TriggerEvent("Pug:client:DoRobberiesAnimation", animationType, PlayerPedId(), false, ObjectData, true)
                                                Wait(5000)
                                            end
                                        end
                                    end

                                    CreateThread(function()
                                        if ChosenAnimation then
                                            if ChosenAnimation.AnimDict then
                                                if ChosenAnimation.AnimAction then
                                                    local startTime = GetGameTimer()
                                                    while GetGameTimer() - startTime < 7000 do
                                                        if not IsEntityPlayingAnim(PlayerPedId(), ChosenAnimation.AnimDict, ChosenAnimation.AnimAction, 3) then
                                                            TriggerEvent("Pug:client:DoRobberiesAnimation", animationType, PlayerPedId(), false, ObjectData, true)
                                                        end
                                                        Wait(1000) -- Check every 1 second
                                                    end
                                                end
                                            end
                                        end
                                    end)

                                    if sellTargetData.sendAlert then
                                        if math.random(1, 100) <= 30 then
                                            SendSuspiciousActivityCallToPolice()
                                        end
                                    end

                                    FreezeEntityPosition(PlayerPedId(), true)
                                    Wait(7000)
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    SellingItems = false

                                    -- Handle delay reward per item
                                    if itemData.delayReward and itemData.rewardDelayTime and tonumber(itemData.rewardDelayTime) > 0 then
                                        local delayTimeInSeconds = tonumber(itemData.rewardDelayTime)
                                        local timeString
                                        
                                        if delayTimeInSeconds >= 3600 then
                                            local hours = math.floor(delayTimeInSeconds / 3600)
                                            timeString = hours .. " hour" .. (hours > 1 and "s" or "")
                                        elseif delayTimeInSeconds >= 60 then
                                            local minutes = math.floor(delayTimeInSeconds / 60)
                                            timeString = minutes .. " minute" .. (minutes > 1 and "s" or "")
                                        else
                                            timeString = delayTimeInSeconds .. " second" .. (delayTimeInSeconds > 1 and "s" or "")
                                        end
                                        
                                        Notify(Config.LangT["WaitBeforeClaimingTrade"] .. timeString .. " before claiming your trade.", "error")
                                        
                                        EndMultipleNetworkAnimation(stage, ObjectData)

                                        -- Add to pending rewards
                                        -- local pendingReward = {
                                        --     itemData = itemData,
                                        --     propCoords = propCoords,
                                        --     propName = propName,
                                        --     readyTime = GetGameTimer() + delayTimeInSeconds * 1000,
                                        --     sellQuantity = sellQuantity,
                                        -- }
                                        -- table.insert(PendingRewards, pendingReward)
                                        -- WaitForReadyTrade()
                                        TriggerServerEvent("Pug:server:SellItems:Trade", tostring(itemData.itemName))
                                    else
                                        -- Give reward immediately
                                        local pendingReward = {
                                            sellQuantity = sellQuantity,
                                        }
                                        -- GiveItemReward(itemData, pendingReward)
                                        TriggerServerEvent("Pug:server:SellItems:Trade", tostring(itemData.itemName))
                                        EndMultipleNetworkAnimation(stage, ObjectData)
                                    end
                                else
                                    Notify(Config.LangT["AlreadySellingItem"], "error")
                                end
                            end
                        })
                    else
                        table.insert(options, {
                            name = 'StartSellItem_' .. itemName,
                            icon = 'fas fa-box',
                            label = itemLabel,
                            distance = 1.5,
                            action = function()
                                if not SellingItems then
                                    SellingItems = true
                                    local requiredQuantity = tonumber(itemData.quantity) or 0
                                    local playerItemCount = GetPlayerItemCount(itemData.itemName)
                                    local sellQuantity = 0

                                    if sellTargetData.sellAllItems then
                                        if playerItemCount < requiredQuantity then
                                            Notify("You do not have enough items to sell.", "error")
                                            SellingItems = false
                                            return
                                        end
                                        sellQuantity = playerItemCount
                                    else
                                        sellQuantity = requiredQuantity
                                        if playerItemCount < sellQuantity then
                                            Notify("You do not have enough items to sell.", "error")
                                            SellingItems = false
                                            return
                                        end
                                    end

                                    if sellQuantity <= 0 then
                                        Notify("Invalid quantity to sell.", "error")
                                        SellingItems = false
                                        return
                                    end

                                    SetEntityCoords(PlayerPedId(), PedCoordsFinal)
                                    local PlayerHeadingHere = tonumber(sellTargetData.playerHeading)
                                    if PlayerHeadingHere then
                                        SetEntityHeading(PlayerPedId(), PlayerHeadingHere)
                                    end
                                    
                                    -- Play animation (if any)
                                    local animationType = sellTargetData.animation
                                    local ObjectData
                                    local stage = {
                                        animation  = animationType,
                                        propName = propName,
                                    }
                                    local ChosenAnimation
                                    if animationType and animationType ~= "" then
                                        ChosenAnimation = Config.Animations[tonumber(animationType)] or Config.RobberyAnimations[animationType]
                                        if ChosenAnimation then
                                            local PropModel = propName
                                            if type(PropModel) == "string" then
                                                PropModel = GetHashKey(propName)
                                            end
                                            local Dist = 1.5
                                            local sceneObject = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), Dist, PropModel, 0, 0, 0)
                                            if sceneObject ~= 0 then
                                                ObjectData = {
                                                    Coords = GetEntityCoords(sceneObject),
                                                    Rotation = GetEntityRotation(sceneObject),
                                                    PropName = propName,
                                                    Heist = "sellitems", -- Update for sell items
                                                    Stage = {},
                                                    DataObject = sceneObject,
                                                    Heading = GetEntityHeading(sceneObject),
                                                }
                                            end
                                            if not ChosenAnimation.ReplaceProp then
                                                TriggerEvent("Pug:client:DoRobberiesAnimation", animationType, PlayerPedId(), false, ObjectData, true)
                                                Wait(5000)
                                            end
                                        end
                                    end

                                    CreateThread(function()
                                        if ChosenAnimation then
                                            if ChosenAnimation.AnimDict then
                                                if ChosenAnimation.AnimAction then
                                                    local startTime = GetGameTimer()
                                                    while GetGameTimer() - startTime < 7000 do
                                                        if not IsEntityPlayingAnim(PlayerPedId(), ChosenAnimation.AnimDict, ChosenAnimation.AnimAction, 3) then
                                                            TriggerEvent("Pug:client:DoRobberiesAnimation", animationType, PlayerPedId(), false, ObjectData, true)
                                                        end
                                                        Wait(1000) -- Check every 1 second
                                                    end
                                                end
                                            end
                                        end
                                    end)

                                    if sellTargetData.sendAlert then
                                        if math.random(1, 100) <= 30 then
                                            SendSuspiciousActivityCallToPolice()
                                        end
                                    end

                                    FreezeEntityPosition(PlayerPedId(), true)
                                    Wait(7000)
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    SellingItems = false

                                    -- Handle delay reward per item
                                    if itemData.delayReward and itemData.rewardDelayTime and tonumber(itemData.rewardDelayTime) > 0 then
                                        local delayTimeInSeconds = tonumber(itemData.rewardDelayTime)

                                        Notify(Config.LangT["WaitBeforeClaimingTrade"] .. itemData.rewardDelayTime .. " seconds before claiming your trade.", "error")
                                        EndMultipleNetworkAnimation(stage, ObjectData)
                                        -- -- Add to pending rewards
                                        -- local pendingReward = {
                                        --     itemData = itemData,
                                        --     propCoords = propCoords,
                                        --     propName = propName,
                                        --     readyTime = GetGameTimer() + delayTimeInSeconds * 1000,
                                        --     sellQuantity = sellQuantity,
                                        -- }
                                        -- table.insert(PendingRewards, pendingReward)
                                        -- WaitForReadyTrade()
                                        TriggerServerEvent("Pug:server:SellItems:Trade", tostring(itemData.itemName))
                                    else
                                        -- Give reward immediately
                                        local pendingReward = {
                                            sellQuantity = sellQuantity,
                                        }
                                        -- GiveItemReward(itemData, pendingReward)
                                        TriggerServerEvent("Pug:server:SellItems:Trade", tostring(itemData.itemName))
                                        EndMultipleNetworkAnimation(stage, ObjectData)
                                    end
                                else
                                    Notify(Config.LangT["AlreadySellingItem"], "error")
                                end
                            end
                        })
                    end
                end
            end
            -- Add the target
            local location = propCoords
            if propName == "tr_prop_tr_elecbox_01a" then
                location = vector3(location[1], location[2], location[3] + 1)
            end
            if GetResourceState("RevoInteract") ~= 'started' and Config.Target and not Config.DrawTextInsteadOfTarget then
                if Config.Target == 'ox_target' then
                    exports.ox_target:addSphereZone({
                        name = targetName,
                        coords = location,
                        radius = 0.5,
                        debug = Config.Debug,
                        options = options
                    })
                else
                    exports[Config.Target]:AddCircleZone(targetName, location, 0.5, {
                        name = targetName,
                        debugPoly = Config.Debug,
                        useZ = true
                    }, {
                        options = options,
                        distance = 1.5
                    })
                end
            end
        else
            -- Add the target
            CreatedTarget[targetName]  = true
            local location = propCoords
            if propName == "tr_prop_tr_elecbox_01a" then
                location = vector3(location[1], location[2], location[3] + 1)
            end
            if GetResourceState("RevoInteract") == 'started' or not Config.Target or Config.DrawTextInsteadOfTarget then
                if GetResourceState("RevoInteract") == 'started' then
                    exports.RevoInteract:OpenHelp({
                        ID = "NOITEMSSOLD", 
                        Text = "YOU DIDN'T ADD ANY ITEMS TO SELL", 
                        Key = "[E]" 
                    })
                else
                    DrawTextOption("[E] YOU DIDN'T ADD ANY ITEMS TO SELL")
                end
                Wait(1000)
                if GetResourceState("RevoInteract") == 'started' then
                    exports.RevoInteract:CloseHelp("NOITEMSSOLD")
                else
                    HideTextOption()
                end
            else
                if Config.Target == 'ox_target' then
                    exports.ox_target:addSphereZone({
                        name = targetName,
                        coords = location,
                        radius = 0.5,
                        debug = Config.Debug,
                        options = {
                            {
                                label = "YOU DIDN'T ADD ANY ITEMS TO SELL",
                            },
                        },
                    })
                else
                    exports[Config.Target]:AddCircleZone(targetName, location, 0.5, {
                        name = targetName,
                        debugPoly = Config.Debug,
                        useZ = true
                    }, {
                        options = {
                            {
                                label = "YOU DIDN'T ADD ANY ITEMS TO SELL",
                            },
                        },
                        distance = 1.5
                    })
                end
            end
        end

    end
end


-- function GiveItemReward(itemData, pendingReward)
--     local rewardMessages = {}

--     -- Reward Items
--     if itemData.rewardItems and #itemData.rewardItems > 0 then
--         for _, rewardItem in ipairs(itemData.rewardItems) do
--             local chance = tonumber(rewardItem.rewardItemChance) or 100
--             if math.random(1, 100) <= chance then
--                 local minAmount = tonumber(rewardItem.rewardItemMin) or 1
--                 local maxAmount = tonumber(rewardItem.rewardItemMax) and tonumber(rewardItem.rewardItemMax) > minAmount and tonumber(rewardItem.rewardItemMax) or minAmount
--                 local rewardItemQuantity = math.random(minAmount, maxAmount)   
--                 if pendingReward then 
--                     rewardItemQuantity = rewardItemQuantity * pendingReward.sellQuantity
--                 end
--                 HandleItems(true, rewardItem.rewardItemName, rewardItemQuantity)
--                 table.insert(rewardMessages, "received " .. rewardItemQuantity .. " " .. rewardItem.rewardItemName)
--             end
--         end
--     end

--     -- Reward Money
--     if itemData.rewardMoneyType and itemData.rewardMoneyMin and itemData.rewardMoneyMax then
--         if tonumber(itemData.rewardMoneyMax) > 0 then
--             if tonumber(itemData.rewardMoneyMin) <= tonumber(itemData.rewardMoneyMax) then
--                 local rewardMoneyAmount = math.random(tonumber(itemData.rewardMoneyMin), tonumber(itemData.rewardMoneyMax))
--                 if pendingReward then
--                     rewardMoneyAmount = rewardMoneyAmount * pendingReward.sellQuantity
--                 end
--                 HandleMoney(itemData.rewardMoneyType, rewardMoneyAmount)
--                 table.insert(rewardMessages, "received $" .. rewardMoneyAmount .. " in " .. itemData.rewardMoneyType)
--             else
--                 Notify(Config.LangT["MaxGreaterThanMinReward"], "error")
--             end
--         end
--     end

--     -- Notify player
--     if #rewardMessages > 0 then
--         local message = "You traded " .. itemData.quantity .. " " .. itemData.itemName .. " and " .. table.concat(rewardMessages, " and ") .. "!"
--         Notify(message)
--     else
--         local message = "You traded " .. itemData.quantity .. " " .. itemData.itemName .. "!"
--         Notify(message)
--     end
-- end

-- function WaitForReadyTrade()
--     CreateThread(function()
--         while true do
--             Wait(1000)
--             if #PendingRewards > 0 then
--                 local currentTime = GetGameTimer()
--                 for i = #PendingRewards, 1, -1 do
--                     local pendingReward = PendingRewards[i]
--                     if currentTime >= pendingReward.readyTime then
--                         -- Create a target to claim the reward
--                         local rewardTargetName = 'rewardTarget_' .. tostring(pendingReward.propCoords[1]) .. "_" .. tostring(math.random(100, 999))
--                         local itemData = pendingReward.itemData
--                         local propCoords = pendingReward.propCoords
--                         local propName = pendingReward.propName

--                         local rewardOptions
--                         if Config.Target == "ox_target" then
--                             rewardOptions = {
--                                 {
--                                     name = 'ClaimReward_' .. itemData.itemName,
--                                     icon = 'fas fa-gift',
--                                     label = 'Claim Reward for ' .. GetItemsInformation(tostring(itemData.itemName)),
--                                     distance = 1.5,
--                                     onSelect = function()
--                                         if Config.Target == 'ox_target' then
--                                             exports.ox_target:removeZone(rewardTargetName)
--                                         else
--                                             exports[Config.Target]:RemoveZone(rewardTargetName)
--                                         end
--                                         GiveItemReward(itemData, pendingReward)
--                                     end
--                                 }
--                             }
--                         else
--                             rewardOptions = {
--                                 {
--                                     name = 'ClaimReward_' .. itemData.itemName,
--                                     icon = 'fas fa-gift',
--                                     label = 'Claim Reward for ' .. GetItemsInformation(tostring(itemData.itemName)),
--                                     distance = 1.5,
--                                     action = function()
--                                         if Config.Target == 'ox_target' then
--                                             exports.ox_target:removeZone(rewardTargetName)
--                                         else
--                                             exports[Config.Target]:RemoveZone(rewardTargetName)
--                                         end
--                                         GiveItemReward(itemData, pendingReward)
--                                     end
--                                 }
--                             }
--                         end

--                         if Config.Target == 'ox_target' then
--                             exports.ox_target:addSphereZone({
--                                 name = rewardTargetName,
--                                 coords = propCoords,
--                                 radius = 0.5,
--                                 debug = Config.Debug,
--                                 options = rewardOptions
--                             })
--                         else
--                             exports[Config.Target]:AddCircleZone(rewardTargetName, propCoords, 0.5, {
--                                 name = rewardTargetName,
--                                 debugPoly = Config.Debug,
--                                 useZ = true
--                             }, {
--                                 options = rewardOptions,
--                                 distance = 1.5
--                             })
--                         end

--                         Notify(Config.LangT["TradeReadyForPickup"], "success")
--                         table.remove(PendingRewards, i)
--                         break
--                     end
--                 end
--             end
--         end
--     end)
-- end

RegisterNetEvent('Pug:client:UpdateSellItemsData', function(ItemsData)
    AllSellItemsData = json.decode(ItemsData)
    RemoveSellItemsTarget()
    if AllSellItemsData.targets then
        CreateSellItemsTarget()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        RemoveSellItemsTarget()
    end
end)
