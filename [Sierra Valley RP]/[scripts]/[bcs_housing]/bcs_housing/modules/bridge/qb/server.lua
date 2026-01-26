loaded = false
CreateThread(function()
    if Config.framework ~= 'QB' then return end
    QBCore = exports[Config.exportname.qb_core]:GetCoreObject()

    if Config.Inventory == 'qb-inventory' or Config.Inventory == 'lj-inventory' or Config.Inventory == 'ak47_inventory' then
        RegisterNetEvent('inventory:server:OpenInventory', function(type, identifier, data)
            local source = source
            pcall(function()
                if GetResourceState('ak47_inventory') == 'started' then
                    -- Add support for ak47_inventory
                    if type == 'player' then
                        -- Open player inventory
                        exports['ak47_inventory']:OpenInventory(identifier)
                    else
                        -- Open stash or custom inventory
                        exports['ak47_inventory']:OpenInventory({
                            identifier = "stash:" .. identifier,
                            label = data.label or "Custom Stash",
                            type = data.type or "stash",
                            maxWeight = data.maxWeight or 120000,
                            slots = data.slots or 50,
                        })
                    end
                else
                    exports[Config.Inventory]:OpenInventory(source, identifier, data)
                end
            end)
        end)
    end

    function RegisterServerCallback(func, ...)
        QBCore.Functions.CreateCallback(func, ...)
    end

    function RegisterUsableItem(name, func)
        QBCore.Functions.CreateUseableItem(name, func)
    end

    function GetPlayerFromId(source)
        local Player = QBCore.Functions.GetPlayer(tonumber(source))
        if Player then
            Player.source = Player.PlayerData.source
            Player.identifier = Player.PlayerData.citizenid
            return Player
        else
            return nil
        end
    end

    function GetPlayerFromIdentifier(identifier)
        local Player = QBCore.Functions.GetPlayerByCitizenId(identifier)
        if Player then
            Player.source = Player.PlayerData.source
            Player.identifier = Player.PlayerData.citizenid
            return Player
        else
            return nil
        end
    end

    loaded = true

    function GetMoney(Player, type, home)
        return Player.Functions.GetMoney(type)
    end

    function RemoveMoney(Player, type, amount, reason, home)
        TriggerEvent('okokBanking:AddNewTransaction', 'Bank', 'bank',
            Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            Player.PlayerData.citizenid,
            amount, reason)
        Player.Functions.RemoveMoney(type, amount, reason)
    end

    function AddMoney(Player, type, amount, reason)
        if type == 'money' then type = 'cash' end
        Player.Functions.AddMoney(type, amount, reason)
    end

    function GetName(Player)
        return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    end

    function GetOfflineName(citizenid)
        local result = MySQL.single.await('SELECT charinfo FROM players WHERE citizenid = ?', { citizenid })
        result.charinfo = json.decode(result.charinfo)
        return result and result.charinfo.firstname .. ' ' .. result.charinfo.lastname or ''
    end

    function GetOfflineJobLabel(name)
        return QBCore.Shared.Jobs[name].label
    end

    function GetJobName(Player)
        return Player.PlayerData.job.name
    end

    function GetJobLabel(Player)
        return Player.PlayerData.job.label
    end

    function GetJobGrade(Player)
        return Player.PlayerData.job.grade.level
    end

    -- Returns the number of online players of a job
    ---@return number
    function CountJob(job)
        local Players = QBCore.Functions.GetQBPlayers()
        local total = 0
        for k, Player in pairs(Players) do
            if Player.PlayerData.job.name == job then
                total += 1
            end
        end
        return total
    end

    ---@param job string
    ---@return table[]
    function GetFrameworkPlayers(job)
        local list = {}
        local Players = QBCore.Functions.GetQBPlayers()
        for k, Player in pairs(Players) do
            Player.source = Player.PlayerData.source
            Player.identifier = Player.PlayerData.identifier
            if job and Player.PlayerData.job.name == job then
                list[#list + 1] = Player
            elseif not job then
                list[#list + 1] = Player
            end
        end
        return list
    end

    function GetOfflineAccount(identifier)
        local result = MySQL.single.await('SELECT money FROM players WHERE citizenid=?', { identifier })
        return next(result) and json.decode(result.money) or {}
    end

    function UpdateOfflineAccount(account, identifier)
        return MySQL.update.await("UPDATE players SET money=? WHERE citizenid=?", { json.encode(account), identifier })
    end

    ---@param xPlayer table
    ---@param admin string
    function CheckAdminGroup(xPlayer, admin)
        return QBCore.Functions.HasPermission(xPlayer.PlayerData.source, admin)
    end

    AddEventHandler('QBCore:Server:PlayerLoaded', function(xPlayer, isNew)
        Player(xPlayer.PlayerData.source).state:set('firstSpawn', true)
        TriggerClientEvent('Housing:client:RegisterDoors', xPlayer.PlayerData.source, doors, doorState)
        TriggerClientEvent('Housing:initialize', xPlayer.PlayerData.source)
        if IsResourceStarted('advancedgarages') then
            local HouseGarages
            for k, v in pairs(Homes) do
                HouseGarages[k] = {
                    label = v.name,
                    takeVehicle = v.data.garage or {}
                }
            end
            TriggerClientEvent('advancedgarages:GetShellGarageData', -1, HouseGarages)
        end
        MySQL.update("UPDATE house_owned SET `lastLogin` = ? WHERE `owner` = ?",
            { os.date('%Y-%m-%d %H:%M:%S', os.time()), xPlayer.PlayerData.citizenid })

        if Config.EnableLastProperty then
            xPlayer.identifier = xPlayer.PlayerData.citizenid
            local homeId, aptId = GetLastProperty(xPlayer)
            if homeId then
                Wait(2500)
                TriggerClientEvent('Housing:client:EnterHome', xPlayer.PlayerData.source, homeId, false, tonumber(aptId))
            end
        end
    end)

    AddEventHandler('QBCore:Server:OnPlayerUnload', function(source)
        TriggerClientEvent('Housing:client:OnLogout', source)
    end)

    Config.SQLQueries[Config.framework] = {
        DeleteNonExistingHouseChar = [[DELETE a
FROM house_owned a
LEFT JOIN players b ON b.citizenid = a.`owner`
WHERE b.citizenid IS NULL]],
        DeleteNonExistingAptChar = [[DELETE a
FROM house_apartment a
LEFT JOIN players b ON b.citizenid = a.`owner`
WHERE b.citizenid IS NULL]],
        GetAptPlayerNames =
        [[SELECT b.identifier, b.apartment,
JSON_UNQUOTE(JSON_EXTRACT(a.charinfo, '$.firstname')) as firstname, JSON_UNQUOTE(JSON_EXTRACT(a.charinfo, '$.lastname')) as lastname
FROM house_apartment b
LEFT JOIN players a ON a.citizenid = b.`owner`]],
        GetHomePlayerNames =
        [[SELECT b.identifier,
JSON_UNQUOTE(JSON_EXTRACT(a.charinfo, '$.firstname')) as firstname, JSON_UNQUOTE(JSON_EXTRACT(a.charinfo, '$.lastname')) as lastname
FROM house_owned b
LEFT JOIN players a ON a.citizenid = b.`owner`]],
        SaveFurniture = "UPDATE players SET furniture = ? WHERE citizenid = ?",
        GetFurniture = 'SELECT furniture FROM players WHERE citizenid = ?',
        SelectFurniture = 'SELECT furniture FROM players WHERE citizenid = @identifier',
        UpdateLastProperty = 'UPDATE players SET last_property=? WHERE citizenid=?',
        GetLastProperty = 'SELECT last_property FROM players WHERE citizenid=?',
        GetPlayerNameByIdentifier =
        "SELECT JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')) as firstname, JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')) as lastname FROM players WHERE citizenid = ?",
        UpdateConfiguration = 'UPDATE house SET configuration = ? WHERE identifier = ?',
        UpdatePermission = 'UPDATE house SET permission = ? WHERE identifier = ?',
        SaveEditHome = 'UPDATE house SET price = ?, payment = ?, data = ? WHERE identifier = ?',
        UpdateData = 'UPDATE house SET data = ? WHERE identifier = ?',
        UpdateEntry = 'UPDATE house SET entry = ? WHERE identifier = ?',
        DeletePlayerOutfit = 'DELETE FROM player_outfits WHERE outfitname = ? AND citizenid = ?',
        SelectPlayerOutfit =
        'SELECT props, components, model FROM player_outfits WHERE citizenid = ? and outfitname = ?',
        GetPlayerOutfits = 'SELECT outfitname as label FROM player_outfits WHERE citizenid = ?'
    }
end)
