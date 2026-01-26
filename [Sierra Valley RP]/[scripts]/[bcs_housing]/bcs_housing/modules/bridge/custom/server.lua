loaded = false
CreateThread(function()
    if Config.framework == 'ESX' or Config.framework == 'QB' then return end
    function RegisterServerCallback(func, ...)
    end

    ---@param name string
    ---@param func function
    function RegisterUsableItem(name, func)
        RegisterUsableItem(name, func)
    end

    ---@param source number
    function GetPlayerFromId(source)
        return GetPlayerFromId(source)
    end

    ---@param identifier string
    function GetPlayerFromIdentifier(identifier)
        return GetPlayerFromIdentifier(identifier)
    end

    loaded = true

    ---@param Player table
    ---@param type string
    ---@param home table Home object
    ---@return number
    function GetMoney(Player, type, home)
        return Player.getAccount(type).money
    end

    ---@param xPlayer table
    ---@param type string
    ---@param amount number
    ---@param home table
    function RemoveMoney(xPlayer, type, amount, reason, home)
        TriggerEvent('okokBanking:AddNewTransaction', 'Bank', 'bank', xPlayer.getName(), xPlayer.identifier,
            amount, reason)
        xPlayer.removeAccountMoney(type, amount)
    end

    ---@param xPlayer table
    ---@param type string
    ---@param amount number
    function AddMoney(xPlayer, type, amount)
        xPlayer.addAccountMoney(type, amount)
    end

    ---@param xPlayer table
    ---@return string
    function GetName(xPlayer)
        return xPlayer.getName()
    end

    function GetOfflineName(identifier)
        -- fetch the name from database and return it
        return 'firstname lastname'
    end

    ---@param xPlayer table
    ---@return string
    function GetJobName(xPlayer)
        return xPlayer.job.name
    end

    ---@param xPlayer table
    ---@return string
    function GetJobLabel(xPlayer)
        return xPlayer.job.label
    end

    ---@param xPlayer table
    ---@return number
    function GetJobGrade(xPlayer)
        return xPlayer.job.grade
    end

    -- Returns the number of online players of a job
    ---@return number
    function CountJob(job)
        return GetPlayers('job', job)
    end

    ---@param job string
    ---@return table[]
    function GetFrameworkPlayers(job)
        if job then
            return ESX.GetExtendedPlayers('job', job)
        else
            return ESX.GetExtendedPlayers()
        end
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

    ---@param source number
    ---@param xPlayer table
    AddEventHandler('framework:playerLoaded', function(source, xPlayer) -- triggered when player logins
        Player(xPlayer.source).state:set('firstSpawn', true)
        TriggerClientEvent('Housing:client:RegisterDoors', -1, doors, doorState)
        TriggerClientEvent('Housing:initialize', xPlayer.source)
        MySQL.update("UPDATE house_owned SET `lastLogin` = ? WHERE `owner` = ?",
            { os.date('%Y-%m-%d %H:%M:%S', os.time()), xPlayer.identifier })

        if Config.EnableLastProperty then
            local homeId, aptId = GetLastProperty(xPlayer)
            if homeId then
                Wait(2500)
                TriggerClientEvent('Housing:client:EnterHome', source, homeId, false, tonumber(aptId))
            end
        end
    end)

    AddEventHandler('framework:Server:OnPlayerUnload', function(source)
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
        GetPlayerNameByIdentifier =
        "SELECT JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')) as firstname, JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')) as lastname FROM players WHERE citizenid = ?",
        UpdateConfiguration = 'UPDATE house SET configuration = ? WHERE identifier = ?',
        UpdatePermission = 'UPDATE house SET permission = ? WHERE identifier = ?',
        SaveEditHome = 'UPDATE house SET price = ?, payment = ?, data = ? WHERE identifier = ?',
        UpdateData = 'UPDATE house SET data = ? WHERE identifier = ?',
        DeletePlayerOutfit = 'DELETE FROM player_outfits WHERE outfitname = ? AND citizenid = ?',
        SelectPlayerOutfit =
        'SELECT props, components, model FROM player_outfits WHERE citizenid = ? and outfitname = ?',
        GetPlayerOutfits = 'SELECT outfitname as label FROM player_outfits WHERE citizenid = ?'
    }
end)
