Config.FrameworkFunctions.CreateCallback('Pug:ServerCB:GetFishingRepAndBoats', function(src, cb)
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    local rep = GetFishingRep(Player)
    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT boats FROM pug_fishing WHERE citizenid = ?', { citizenid }, function(results)
        local owned = {}
        if results[1] then
            local data = json.decode(results[1].boats or "[]")
            for _, model in ipairs(data) do
                owned[model] = true
            end
        end
        cb(rep, owned)
    end)
end)


RegisterNetEvent('Pug:Server:BuyBoat', function(model)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local rep = GetFishingRep(Player)

    for _, boat in ipairs(Config.Boats) do
        if boat.model == model then
            if rep < boat.xpRequired then return end

            local money = Player.PlayerData.money.cash or 0
            if money < boat.cost then
                TriggerClientEvent('Pug:client:FishingNotify', src, Translations.error.not_enough_cash .. boat.cost .. ")", "error")
                return
            end
            MySQL.query('SELECT boats FROM pug_fishing WHERE citizenid = ?', { citizenid }, function(results)
                if not results[1] then return end
                local owned = json.decode(results[1].boats or "[]")

                for _, v in ipairs(owned) do
                    if v == model then
                        TriggerClientEvent('Pug:client:FishingNotify', src, Translations.error.already_own_boat, "error")
                        return
                    end
                end

                table.insert(owned, model)
                Player.RemoveMoney('cash', boat.cost)
                MySQL.update('UPDATE pug_fishing SET boats = ? WHERE citizenid = ?', {
                    json.encode(owned), citizenid
                })
                TriggerClientEvent('Pug:client:FishingNotify', src, Translations.success.purchased_boat .. boat.name .. "!", "success")
            end)

            break
        end
    end
end)

local StashCreated = {}
RegisterNetEvent("Pug:server:BoatStashCreate", function(StashName, Slots, Space)
    if not StashCreated[StashName] then
        StashCreated[StashName] = true
        exports.ox_inventory:RegisterStash(
            StashName, 
            StashName, 
            Slots, 
            Space
        )
    end
end)
