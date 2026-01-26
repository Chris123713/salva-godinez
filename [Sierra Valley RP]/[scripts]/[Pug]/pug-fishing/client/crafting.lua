if craftingbench == nil then
	RequestModel(GetHashKey("prop_tool_bench02"))
	while not HasModelLoaded(GetHashKey("prop_tool_bench02")) do Wait(1) end
	craftingbench = CreateObject(GetHashKey("prop_tool_bench02"), vector3(Config.CrafingRodLocation.x, Config.CrafingRodLocation.y, Config.CrafingRodLocation.z-1),false,false,false)
	SetEntityHeading(craftingbench,Config.CrafingRodLocation.w+90)
	FreezeEntityPosition(craftingbench, true)
	PugAddTargetToEntity(craftingbench, {
		{
			name  = "CraftFishingRod",
			type  = "client",
			event = "Pug:client:CraftFishingRodMenu",
			icon  = "fa-solid fa-pen-ruler",
			label = Translations.menu.CraftRodHeader,
			distance = 1.5, 
		},
	})
end

RegisterNetEvent('Pug:client:CraftFishingRodMenu', function()
    Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:GetFishingRep', function(rep)
        local menu = {}
        local rankInfo = GetRankInfoFromXP(rep)

        table.insert(menu, {
            title       = ("Rank %d - %s"):format(rankInfo.level, rankInfo.title),
            description = ("Progress to Next Rank: %d%%"):format(rankInfo.percent),
            icon        = "fa-solid fa-user",
            iconColor   = "#1e90ff",
            colorScheme = '#1e90ff',
            progress    = rankInfo.percent,
            readOnly    = true
        })

        for k, v in pairs(Config.CraftRods) do
            local playerRankIndex = GetRankIndex(rankInfo.title)
            local requiredRankIndex = GetRankIndex(v.requiredRank)
            local hasRequiredRank = playerRankIndex >= requiredRankIndex

            local filename, craftedLabel = ShowItemLable(k, true)
            local image = GetItemImage(filename)

            local reqParts = {}
            if v.requirements and type(v.requirements) == "table" then
                for _, req in ipairs(v.requirements) do
                    local amt = tonumber(req and req.amount or 1) or 1
                    local lbl = ShowItemLable(req and req.item)
                    if lbl and amt > 0 then
                        reqParts[#reqParts + 1] = (("%dx %s"):format(amt, lbl))
                    end
                end
            end

            local descriptionText = (#reqParts > 0) and ("Required: " .. table.concat(reqParts, " | ")) or "Required: -"

            table.insert(menu, {
                title = ("%s | Rank: %s | $%d"):format(craftedLabel, v.requiredRank, v.price or 0),
                description = descriptionText,
                icon = image,
                image = image,
                iconColor = hasRequiredRank and "#32cd32" or "#808080",
                event = hasRequiredRank and "Pug:client:CraftFishingRod" or nil,
                args = k,
                readOnly = not hasRequiredRank,
            })
        end

        PugCreateMenu("craft_rods", Translations.menu.CraftRodHeader, menu)
    end)
end)



RegisterNetEvent("Pug:client:CraftFishingRod", function(item)
    Config.FrameworkFunctions.TriggerCallback('Pug:ServerCB:CanCraftRod', function(cancraft)
        if not cancraft then return end

        local dict, anim = "mini@repair", "fixing_a_ped"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(10) end
        TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, -1, 49, 0, false, false, false)

        PugProgressBar("crafint_rod", Translations.details.Crafting_rod, 7000, {
            disables = { disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true },
            anim = {}
        }, function()
            local rod = Config.CraftRods and Config.CraftRods[item]
            if not rod or type(rod.requirements) ~= "table" then
                print(('[Crafting] Missing config data for %s'):format(tostring(item)))
                return
            end

            local ok = true
            for _, req in ipairs(rod.requirements) do
                local it = req and req.item
                local amt = tonumber(req and req.amount or 1) or 1
                if it and amt > 0 then
                    if not HasItem(it, amt) then ok = false break end
                end
            end

            if not ok then
                FishingNotify(Translations.details.canceled .. " DONT TRY TO EXPLOIT", "error")
                return
            end

            for _, req in ipairs(rod.requirements) do
                local it = req and req.item
                local amt = tonumber(req and req.amount or 1) or 1
                if it and amt > 0 then
                    PugFishToggleItem(false, it, amt)
                end
            end

            TriggerServerEvent("Pug:server:FishingRemoveMoeny", tonumber(rod.price or 0) or 0)
            PugFishToggleItem(true, item, 1)
            FishingNotify(Translations.details.crafted_rod .. (rod.name or item))

            if Config.RemoveFishingRepWhenCraftRod and rod.repRequired and rod.repRequired > 0 then
                TriggerServerEvent("Pug:server:RemoveFishingRep", rod.repRequired)
            end
        end, function()
            FishingNotify(Translations.details.canceled, "error")
        end)
    end, item)
end)


AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
		DeleteEntity(craftingbench)
	end
end)